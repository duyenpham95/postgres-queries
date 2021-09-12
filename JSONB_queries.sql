DROP TABLE app;
CREATE TABLE app (
   id uuid UNIQUE NOT NULL, --PRIMARY KEY
   song_params jsonb
);

insert into app values 
(uuid_generate_v4(), '[{"key": "t1", "is_default": "false"},
											{"key": "t2", "is_default": "true"}]'),
(uuid_generate_v4(), '[{"key": "t3", "is_default": null},
											{"key": "t4", "is_default": null}]'),
(uuid_generate_v4(), '[{"key": "t5", "is_default": null},
											{"key": "t6", "is_default": "false"},
											{"key": "t7", "is_default": null}]');
											
select * from app;

-- query jsonb by key and value					
WITH null_is_default AS (
	SELECT
	 ('{' ||INDEX - 1||', is_default}')::TEXT[] AS PATH,
	 app.id AS app_id
	FROM 
		app, jsonb_array_elements (app.song_params) WITH ORDINALITY arr(song_param, index)
	WHERE 
	song_param ->> 'is_default' is null
)
select * from null_is_default;

---- UPDATE all is_default = null to true
DO 
$$
DECLARE
	 rec record;
BEGIN 
	FOR rec IN 
		SELECT
		 app.id as app_id, ('{' ||index - 1||', is_default}')::text[] as path_arg
		FROM 
			app, jsonb_array_elements (app.song_params) WITH ORDINALITY arr(song_param, index)
		WHERE 
		song_param ->> 'is_default' is null
  loop
			update app set song_params = jsonb_set(song_params, rec.path_arg, 'true', false)
			where app.id = rec.app_id;
			
			RAISE NOTICE 'call update query: app_id % %', rec.app_id, rec.path_arg;
  end loop;
end$$;