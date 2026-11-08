-- StudyFlow · Universidades de Cali que se ofrecen en el registro.
insert into public.universidades (nombre, dominio_correo) values
  ('Universidad Icesi', 'u.icesi.edu.co'),
  ('Pontificia Universidad Javeriana Cali', 'javerianacali.edu.co'),
  ('Universidad del Valle', 'correounivalle.edu.co'),
  ('Universidad Autónoma de Occidente', 'uao.edu.co'),
  ('Universidad de San Buenaventura Cali', 'usbcali.edu.co')
on conflict (dominio_correo) do nothing;
