// StudyFlow · Edge Function "asistente" (Sprint 3).
//
// La app manda la pregunta del estudiante; esta función:
// 1. revisa quién es (JWT de Supabase) y lee SUS actividades pendientes con su
//    propia sesión, así el RLS sigue aplicando y nadie ve datos ajenos;
// 2. revisa en el servidor el límite del plan gratis (5 respuestas de la IA por
//    semana, desde el lunes) o si tiene Plus;
// 3. le pregunta a Gemini y devuelve { respuesta }.
//
// Si no hay llave de la IA, si la IA falla o tarda, o si ya no le quedan
// consultas, responde con un error y la app usa el orden de respaldo (no gasta
// consulta). La llave se guarda como secreto GEMINI_API_KEY en Supabase.
import { createClient } from "jsr:@supabase/supabase-js@2";

const MODELO = "gemini-2.5-flash";
const CONSULTAS_GRATIS = 5;
const ESPERA_MS = 15_000;
const ZONA = "America/Bogota";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(cuerpo: unknown, status = 200): Response {
  return new Response(JSON.stringify(cuerpo), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

/// Lunes 00:00 (hora de Colombia, UTC-5) de la semana actual, en UTC.
function inicioDeSemana(ahora: Date): Date {
  const local = new Date(ahora.getTime() - 5 * 3600_000);
  const diasDesdeLunes = (local.getUTCDay() + 6) % 7;
  const lunes = Date.UTC(local.getUTCFullYear(), local.getUTCMonth(), local.getUTCDate() - diasDesdeLunes);
  return new Date(lunes + 5 * 3600_000);
}

const fechaLocal = new Intl.DateTimeFormat("es-CO", {
  timeZone: ZONA,
  weekday: "short",
  day: "numeric",
  month: "short",
  hour: "numeric",
  minute: "2-digit",
});

type Actividad = {
  titulo: string;
  tipo: string;
  fecha_limite: string;
  porcentaje: number;
  prioridad: string;
  estado: string;
  componentes_nota: { materias: { nombre: string } | null } | null;
};

const CERRADAS = new Set(["completada", "no_entregada", "presentado"]);

function describir(a: Actividad): string {
  const materia = a.componentes_nota?.materias?.nombre ?? "Sin materia";
  return `- ${a.titulo} (${a.tipo}, ${materia}) · vence ${fechaLocal.format(new Date(a.fecha_limite))} · ` +
    `vale ${a.porcentaje} % · prioridad ${a.prioridad} · estado ${a.estado}`;
}

const INSTRUCCIONES = `Eres el asistente de StudyFlow, un organizador académico para universitarios en Colombia.
Respondes en español latinoamericano, cercano y claro, en máximo 120 palabras.
Ayudas a decidir qué hacer primero y cuánto tiempo estudiar, usando SOLO las actividades pendientes que te paso.
Para ordenar: primero lo que vence antes; si vencen el mismo día, lo que vale más porcentaje; luego la prioridad.
Si la pregunta no es sobre estudio u organización académica, dilo en una frase y vuelve a sus pendientes.
No inventes actividades, fechas ni notas. No uses tablas ni encabezados; puedes usar una lista corta numerada.`;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "metodo_no_permitido" }, 405);

  // Cliente con la sesión del usuario: todo lo que lea pasa por el RLS.
  const auth = req.headers.get("Authorization") ?? "";
  const db = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: auth } },
  });
  const { data: usuario } = await db.auth.getUser(auth.replace(/^Bearer\s+/i, ""));
  if (!usuario.user) return json({ error: "sin_sesion" }, 401);

  let pregunta = "";
  try {
    pregunta = String((await req.json())?.pregunta ?? "").trim();
  } catch {
    // cuerpo inválido: se responde abajo
  }
  if (!pregunta || pregunta.length > 1000) return json({ error: "pregunta_invalida" }, 400);

  // Límite del plan gratis, revisado aquí y no solo en la app.
  const [plus, usadas] = await Promise.all([
    db.from("suscripciones").select("id").in("estado", ["en_prueba", "activa"]).limit(1),
    db.from("mensajes_asistente")
      .select("id", { count: "exact", head: true })
      .eq("rol", "asistente")
      .eq("usado_respaldo", false)
      .gte("creado_en", inicioDeSemana(new Date()).toISOString()),
  ]);
  const esPlus = (plus.data?.length ?? 0) > 0;
  if (!esPlus && (usadas.count ?? 0) >= CONSULTAS_GRATIS) {
    return json({ error: "sin_consultas" }, 429);
  }

  const llave = Deno.env.get("GEMINI_API_KEY");
  if (!llave) return json({ error: "ia_no_configurada" }, 503);

  const { data: filas, error } = await db
    .from("actividades")
    .select("titulo, tipo, fecha_limite, porcentaje, prioridad, estado, " +
      "componentes_nota!inner(materias!inner(nombre, periodos!inner(activo)))")
    .eq("componentes_nota.materias.periodos.activo", true)
    .order("fecha_limite", { ascending: true })
    .limit(40);
  if (error) return json({ error: "sin_datos" }, 500);
  const pendientes = (filas as unknown as Actividad[]).filter((a) => !CERRADAS.has(a.estado));

  const contexto = `Hoy es ${fechaLocal.format(new Date())}.\n` +
    (pendientes.length
      ? `Actividades pendientes del estudiante:\n${pendientes.map(describir).join("\n")}`
      : "El estudiante no tiene actividades pendientes.");

  try {
    const res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${MODELO}:generateContent`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json", "x-goog-api-key": llave },
        signal: AbortSignal.timeout(ESPERA_MS),
        body: JSON.stringify({
          systemInstruction: { parts: [{ text: INSTRUCCIONES }] },
          contents: [{ role: "user", parts: [{ text: `${contexto}\n\nPregunta: ${pregunta}` }] }],
          generationConfig: { temperature: 0.4, maxOutputTokens: 400, thinkingConfig: { thinkingBudget: 0 } },
        }),
      },
    );
    if (!res.ok) return json({ error: "ia_fallo", status: res.status }, 502);
    const datos = await res.json();
    const respuesta = (datos?.candidates?.[0]?.content?.parts ?? [])
      .map((p: { text?: string }) => p.text ?? "")
      .join("")
      .trim();
    if (!respuesta) return json({ error: "ia_vacia" }, 502);
    return json({ respuesta });
  } catch {
    return json({ error: "ia_no_responde" }, 504);
  }
});
