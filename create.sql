DROP TABLE IF EXISTS pojazdy CASCADE ;
DROP TABLE IF EXISTS kierowcy CASCADE;
DROP TABLE IF EXISTS kierowcy_pojazdy CASCADE;
DROP TABLE IF EXISTS prawa_jazdy CASCADE;
DROP TABLE IF EXISTS prawa_jazdy_kategorie CASCADE;
DROP TYPE IF EXISTS typ_egzaminu CASCADE;
DROP TABLE IF EXISTS wyniki_egzaminów CASCADE;
DROP TYPE IF EXISTS wynik_egzaminu CASCADE;
DROP TABLE IF EXISTS egzaminatorzy CASCADE;
DROP TABLE IF EXISTS egzaminy CASCADE;
DROP TABLE IF EXISTS ośrodki CASCADE;
DROP TABLE IF EXISTS mandaty CASCADE;
DROP TABLE IF EXISTS mandaty_wystawiający CASCADE;
DROP TABLE IF EXISTS wykroczenia CASCADE ;

CREATE TABLE pojazdy(
	id_pojazdu SERIAL PRIMARY KEY,
	nr_rejestracyjny CHAR(7) UNIQUE ,
	/* VIN */
	data_rejestracji DATE NOT NULL,
	/* Id_właściciela*/
	marka TEXT,
	model TEXT,
	typ TEXT
	/*ciężar*/
);
CREATE TABLE kierowcy(
	id_kierowcy SERIAL PRIMARY KEY,
	PESEL CHAR(11) NOT NULL UNIQUE , /* Na pewno char?*/
	imię VARCHAR(50) NOT NULL ,
	nazwisko VARCHAR(50) NOT NULL ,
	email TEXT, /*CHECK*/
	nr_telefonu CHAR(9), /*CHAR(9)?*/
	adres TEXT
	/*	polskie_prawo_jazdy TEXT, /*CHECK FORMAT*/
		międzynarodowe_prawo_jazdy TEXT /*CHECK FORMAT*/
		nie potrzebne bo informacja jest w tabeli prawa jazdy
	*/
);

CREATE TABLE kierowcy_pojazdy(
id_kierowcy INT NOT NULL REFERENCES kierowcy,
id_pojazdu INT NOT NULL REFERENCES pojazdy,
PRIMARY KEY (id_kierowcy,id_pojazdu)
);

CREATE TABLE prawa_jazdy(
	numer_prawa_jazdy TEXT PRIMARY KEY ,
	id_właściciela INT REFERENCES kierowcy(id_kierowcy),
	/*kategoria - osobna tabela jedno prawo jazdy wiele kategorii*/
	data_wydania DATE NOT NULL,
	międzynarodowe BOOL NOT NULL
);

CREATE TABLE prawa_jazdy_kategorie(
	numer_prawa_jazdy TEXT REFERENCES prawa_jazdy,
	kategoria TEXT NOT NULL ,
	PRIMARY KEY (numer_prawa_jazdy,kategoria)
);

CREATE TYPE TYP_EGZAMINU AS ENUM ('teoria','praktyka');


CREATE TABLE egzaminatorzy(
	id_egzaminatora SERIAL PRIMARY KEY ,
	imię VARCHAR(50) NOT NULL ,
	nazwisko VARCHAR(50) NOT NULL
	/*Numer licencji */
);
CREATE TABLE ośrodki(
	id_ośrodka SERIAL PRIMARY KEY ,
	nazwa TEXT NOT NULL ,
	adres TEXT
	/* Identyfikator czy coś*/
);
CREATE TABLE egzaminy(
	id_egzaminu SERIAL PRIMARY KEY,
	data_przeprowadzenia DATE NOT NULL ,
	typ TYP_EGZAMINU NOT NULL ,
	id_egzaminatora INT NOT NULL REFERENCES egzaminatorzy NOT NULL ,
	id_ośrodka INT NOT NULL REFERENCES ośrodki(id_ośrodka)
	/*id_zdającego,
	wynik - enum zdał, nie zdał, nie stawił się, przeniesiony,...
	wynik punktowy
	osobna tabela 1 egzamin wielu zdających*/
);

CREATE TYPE WYNIK_EGZAMINU AS ENUM('zdał', 'nie zdał', 'nie stawił się');

CREATE TABLE wyniki_egzaminów(
	id_egzaminu INT REFERENCES egzaminy NOT NULL ,
	id_kierowcy INT REFERENCES kierowcy NOT NULL ,
	wynik WYNIK_EGZAMINU NOT NULL ,
	PRIMARY KEY (id_egzaminu,id_kierowcy)
);

CREATE TABLE mandaty_wystawiający(
	id_wstawiającego SERIAL PRIMARY KEY ,
	imię VARCHAR(50) NOT NULL ,
	nazwisko VARCHAR(50) NOT NULL
);

CREATE TABLE wykroczenia(
	id_wykroczenia SERIAL PRIMARY KEY,
	opis TEXT,
	wysokość_grzywny NUMERIC(7,2),
	punkty_karne NUMERIC(2) NOT NULL
);

CREATE TABLE mandaty(
	id_mandatu SERIAL PRIMARY KEY,
	id_kierowcy INT REFERENCES kierowcy NOT NULL ,
	id_wystawiającego INT REFERENCES mandaty_wystawiający(id_wstawiającego) NOT NULL ,
	id_wykroczenia INT REFERENCES wykroczenia NOT NULL
);

--Sprawdzanie poprawnosci wprowadzanego numeru pesel
CREATE OR REPLACE FUNCTION pesel_check() RETURNS trigger AS $$
BEGIN
      IF LENGTH(NEW.pesel) < 11 THEN
              RAISE EXCEPTION 'Niepoprawny PESEL';
      END IF;
      IF(((CAST(substring(NEW.pesel,1,1) AS INT)) * 1 +
         (CAST(substring(NEW.pesel,2,1) AS INT)) * 3 +
         (CAST(substring(NEW.pesel,3,1) AS INT)) * 7 +
         (CAST(substring(NEW.pesel,4,1) AS INT)) * 9 +
         (CAST(substring(NEW.pesel,5,1) AS INT)) * 1 +
         (CAST(substring(NEW.pesel,6,1) AS INT)) * 3 +
         (CAST(substring(NEW.pesel,7,1) AS INT)) * 7 +
         (CAST(substring(NEW.pesel,8,1) AS INT)) * 9 +
         (CAST(substring(NEW.pesel,9,1) AS INT)) * 1 +
         (CAST(substring(NEW.pesel,10,1) AS INT)) * 3 +
         (CAST(substring(NEW.pesel,11,1) AS INT)) * 1) % 10 <> 0)
      THEN
              RAISE EXCEPTION 'Niepoprawny PESEL';
      END IF;
      RETURN NEW;

END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS pesel_check ON kierowcy;

CREATE TRIGGER pesel_check BEFORE INSERT OR UPDATE ON kierowcy
FOR EACH ROW EXECUTE PROCEDURE pesel_check();

--wypis id pojazdow ktorych wlascicielem jest kierowca o id_k
DROP FUNCTION IF EXISTS pojazdy(integer);

CREATE OR REPLACE FUNCTION pojazdy(id_k INT)
RETURNS SETOF INT AS
$$
SELECT id_pojazdu 
FROM kierowcy_pojazdy
WHERE id_kierowcy = id_k;
$$ LANGUAGE sql;

--wypis numeru prawa jazdy kierowcy o id_k
DROP FUNCTION IF EXISTS nr_prawa_jazdy(integer);

CREATE OR REPLACE FUNCTION nr_prawa_jazdy(id_k INT)
RETURNS text AS
$$
DECLARE 
	nr text;
BEGIN
	nr = (SELECT numer_prawa_jazdy FROM prawa_jazdy
	WHERE id_właściciela = id_k
	LIMIT 1);

	RETURN nr;
END;
$$ LANGUAGE plpgsql;

--id miedzynarodowego prawa jazdy kierowcy o id_k
DROP FUNCTION IF EXISTS nr_prawa_jazdy_M(integer);

CREATE OR REPLACE FUNCTION nr_prawa_jazdy_M(id_k INT)
RETURNS text AS
$$
DECLARE 
	nr text;
BEGIN
	nr = (SELECT numer_prawa_jazdy FROM prawa_jazdy
	WHERE id_właściciela = id_k AND międzynarodowe IS TRUE
	LIMIT 1);

	RETURN nr;
END;
$$ LANGUAGE plpgsql;

--ilosc mandatow kierowcy o id_k
DROP FUNCTION IF EXISTS ilosc_mandatow(integer);

CREATE OR REPLACE FUNCTION ilosc_mandatow(id_k INT)
RETURNS INTEGER AS
$$
DECLARE 
	nr INTEGER;
BEGIN
	nr = (
	SELECT COUNT(id_mandatu) 
	FROM mandaty
	WHERE id_kierowcy = id_k);

	RETURN nr;
END;
$$ LANGUAGE plpgsql;

--sprawdzenie dla danego kierowcy o id_k ile zdobyl punktow karnych
DROP FUNCTION IF EXISTS ile_punktow(integer);

CREATE OR REPLACE FUNCTION ile_punktow(id_k INT)
RETURNS NUMERIC AS
$$
SELECT SUM(punkty_karne) 
FROM (
      SELECT punkty_karne
      FROM mandaty INNER JOIN wykroczenia ON mandaty.id_wykroczenia = wykroczenia.id_wykroczenia
      WHERE mandaty.id_kierowcy = id_k) AS tab;
$$ LANGUAGE sql;

--ilosc podejsc do egzaminu na prawo jazdy kierowcy o id_k
DROP FUNCTION IF EXISTS ilosc_egzaminow(integer);

CREATE OR REPLACE FUNCTION ilosc_egzaminow(id_k INT)
RETURNS INTEGER AS
$$
DECLARE 
	nr INTEGER;
BEGIN
	nr = (
	SELECT COUNT(id_egzaminu) 
	FROM wyniki_egzaminów
	WHERE id_kierowcy = id_k);

	RETURN nr;
END;
$$ LANGUAGE plpgsql;

--id ostatniego egzaminu danego kierowcy o id_k
DROP FUNCTION IF EXISTS ostatni_egzamin(integer);

CREATE OR REPLACE FUNCTION ostatni_egzamin(id_k INT)
RETURNS INTEGER AS
$$
DECLARE 
	nr INTEGER;
BEGIN
	nr = (
	SELECT egzaminy.id_egzaminu
	FROM wyniki_egzaminów
	INNER JOIN egzaminy ON wyniki_egzaminów.id_egzaminu = egzaminy.id_egzaminu
	WHERE id_kierowcy = id_k
	ORDER BY data_przeprowadzenia DESC
	LIMIT 1);

	RETURN nr;
END;
$$ LANGUAGE plpgsql;

--dla danego numeru rejestracji wypisuje imiona_i_naziwska_osob_z_bazy_ktorego maja go przypisanego
DROP FUNCTION IF EXISTS imie_i_nazwisko_wlasciciela_samochodu(char(7));

CREATE OR REPLACE FUNCTION imie_i_nazwisko_wlasciciela_samochodu(id_p char(7))
RETURNS SETOF text AS
$$
SELECT CONCAT(imię, ' ', nazwisko)
FROM pojazdy NATURAL JOIN kierowcy_pojazdy
NATURAL JOIN kierowcy
WHERE nr_rejestracyjny = id_p
$$ LANGUAGE sql;

--statystki ile jest w bazie pojazdow jakiej marki i modelu
DROP VIEW IF EXISTS statystyki_pojazdow_markaModel;

CREATE OR REPLACE VIEW statystyki_pojazdow_markaModel
AS
SELECT marka, model, COUNT(id_pojazdu)
FROM pojazdy
GROUP BY marka, model;

--statystyki pojazdow po roku rejestracji 
DROP VIEW IF EXISTS statystyki_pojazdow_rokRejestracji;

CREATE OR REPLACE VIEW statystyki_pojazdow_rokRejestracji
AS
SELECT EXTRACT(YEAR FROM data_rejestracji) AS rok, COUNT(id_pojazdu) AS ilosc
FROM pojazdy
GROUP BY rok
ORDER BY rok;

--statystyki zdawalnosci egzaminow
DROP VIEW IF EXISTS statystyki_zdawalnosci_egzaminow;

CREATE OR REPLACE VIEW statystyki_zdawalnosci_egzaminow
AS
SELECT wynik, typ, COUNT(id_egzaminu)
FROM egzaminy
NATURAL JOIN wyniki_egzaminów
GROUP BY wynik, typ;

--dodawanie danych do bazy
INSERT INTO kierowcy VALUES (1, '72041483630', 'Miłosz', 'Sokołowski', 'atyeaveht@gmail.com', '702547963', 'Piaski 38/95');
INSERT INTO kierowcy VALUES (2, '72122819152', 'Oskar', 'Grabowski', 'hracyjvo@interia.pl', '729890640', 'Dębowa 21/54');
INSERT INTO kierowcy VALUES (3, '46031861920', 'Nadia', 'Bąk', 'cev@gmail.com', '760102213', 'Urodzaju 77/47');
INSERT INTO kierowcy VALUES (4, '98083144418', 'Wiktor', 'Sokołowski', 'lzr@o2.pl', '699195338', 'Aleksandra Puszkina 59/80');
INSERT INTO kierowcy VALUES (5, '57112869221', 'łucja', 'Duda', 'scp@gmail.com', '598809949', 'Łącząca 74/45');
INSERT INTO kierowcy VALUES (6, '23100280796', 'Piotr', 'Konieczny', 'cfefx@gmail.com', '749329628', 'Piesza 34/79');
INSERT INTO kierowcy VALUES (7, '94032810771', 'Maksymilian', 'Urbański', 'kdqrjvrs@interia.pl', '651847249', 'Średnia 19/62');
INSERT INTO kierowcy VALUES (8, '28051052494', 'Igor', 'Wróbel', 'brvnmm@wp.pl', '719015932', 'Feliksa Falskiego 05/88');
INSERT INTO kierowcy VALUES (9, '83081789378', 'Michał', 'Maciejewski', 'wjvrwjdbskc@interia.pl', '707926296', 'Stanisława Dubois 82/95');
INSERT INTO kierowcy VALUES (10, '51111461354', 'Kamil', 'Marciniak', 'plytdkxnyth@interia.pl', '690262082', 'Os. Świerkle 13/65');
INSERT INTO kierowcy VALUES (11, '98060643840', 'Lilianna', 'Głowacka', 'ltfasyhy@gmail.com', '802525541', 'Kłosowa 79/33');
INSERT INTO kierowcy VALUES (12, '82122465178', 'Oliwier', 'Michalski', 'cjgwiow@interia.pl', '640895358', 'Urocza 37/68');
INSERT INTO kierowcy VALUES (13, '19050124806', 'Barbara', 'Duda', 'ymhwwx@interia.pl', '745226872', 'Warłowska 07/67');
INSERT INTO kierowcy VALUES (14, '94011703094', 'Michał', 'Konieczny', 'jyorvkoqqb@wp.pl', '612914733', 'Chróstecka 00/00');
INSERT INTO kierowcy VALUES (15, '25092251222', 'Liliana', 'Mazurek', 'xfkn@interia.eu', '582324230', 'Zatorze 63/79');
INSERT INTO kierowcy VALUES (16, '59100964723', 'Julia', 'Kalinowska', 'cmezron@wp.pl', '670095347', 'Przyszłości 11/62');
INSERT INTO kierowcy VALUES (17, '46042330796', 'Krzysztof', 'Błaszczyk', 'ichjt@wp.pl', '570401576', 'Ks. Józefa Tischnera 43/37');
INSERT INTO kierowcy VALUES (18, '65033150292', 'Piotr', 'Kowalczyk', 'wip@o2.pl', '860158310', 'Bogacka 67/28');
INSERT INTO kierowcy VALUES (19, '17022749015', 'Gabriel', 'Zalewski', 'xmx@interia.pl', '815693628', 'Wielkie Przedmieście 79/64');
INSERT INTO kierowcy VALUES (20, '13010985041', 'Zuzanna', 'Duda', 'aflrcyqg@interia.pl', '577713112', 'Matejki 38/21');
INSERT INTO kierowcy VALUES (21, '13120411267', 'Katarzyna', 'Nowak', 'avvfvmlek@interia.eu', '890901184', 'Kolonia 37/36');
INSERT INTO kierowcy VALUES (22, '24122891478', 'Leon', 'Kołodziej', 'erqsewcrwl@wp.pl', '835231381', 'Park Orderu Uśmiechu 40/33');
INSERT INTO kierowcy VALUES (23, '67050809386', 'Helena', 'Kaczmarek', 'nijrah@interia.pl', '889024263', 'Ratuszowa 57/58');
INSERT INTO kierowcy VALUES (24, '43102604790', 'Filip', 'Czarnecki', 'vkr@o2.pl', '898949051', 'Guznera 99/84');
INSERT INTO kierowcy VALUES (25, '87082602308', 'Anna', 'Szulc', 'xuodqbwxe@o2.pl', '604409870', 'Agrestowa 74/27');
INSERT INTO kierowcy VALUES (26, '69121561210', 'Igor', 'Olszewski', 'pskso@wp.pl', '586841959', 'Józefa Ignacego Kraszewskiego 58/81');
INSERT INTO kierowcy VALUES (27, '75030416541', 'Kinga', 'Krupa', 'rqh@interia.pl', '532912506', 'Słodka 11/91');
INSERT INTO kierowcy VALUES (28, '28061500202', 'Małgorzata', 'Kołodziej', 'mljcebl@interia.eu', '646888584', 'Marca go Marca 15/52');
INSERT INTO kierowcy VALUES (29, '83091946354', 'Tymon', 'Woźniak', 'jpu@wp.pl', '631546126', 'Żużlowa 04/56');
INSERT INTO kierowcy VALUES (30, '22040235158', 'Sebastian', 'Kubiak', 'omfxwusk@o2.pl', '837690872', 'Pl. Św. Józefa 17/68');
INSERT INTO kierowcy VALUES (31, '20112497989', 'Helena', 'Górecka', 'dhfbdzlu@wp.pl', '654265085', 'Rzędowicka 54/47');
INSERT INTO kierowcy VALUES (32, '64040905523', 'Marta', 'Maciejewska', 'uijzhwt@interia.eu', '652437614', 'Köellinga 88/58');
INSERT INTO kierowcy VALUES (33, '29102757782', 'Martyna', 'Błaszczyk', 'ccvbjsxgpsg@o2.pl', '815267062', 'Wieniawskiego 14/52');
INSERT INTO kierowcy VALUES (34, '36041847618', 'Maciej', 'Kaczmarczyk', 'wsoeiinrf@wp.pl', '676273404', 'Czarnowąska 56/52');
INSERT INTO kierowcy VALUES (35, '40020639190', 'Miłosz', 'Kowalski', 'qioavffbo@interia.pl', '705175573', 'Raszowska 55/57');
INSERT INTO kierowcy VALUES (36, '42020288145', 'Nina', 'Zielińska', 'zmhhr@interia.eu', '835006783', 'Al. Lipowa 18/38');
INSERT INTO kierowcy VALUES (37, '31111268052', 'Dominik', 'Witkowski', 'nhkzqrsbphk@o2.pl', '528256340', 'Stelmacha 71/95');
INSERT INTO kierowcy VALUES (38, '26012657157', 'Marcel', 'Lis', 'lpeoelbjv@wp.pl', '639863012', 'Św. Karola Boromeusza 07/29');
INSERT INTO kierowcy VALUES (39, '53012458440', 'Barbara', 'Król', 'ppgdqqyqny@gmail.com', '860782002', 'Nadodrzańska 92/86');
INSERT INTO kierowcy VALUES (40, '46092961441', 'Klaudia', 'Kaźmierczak', 'ibvirkim@interia.eu', '821764908', 'Traugutta 26/72');
INSERT INTO kierowcy VALUES (41, '17091806084', 'Emilia', 'Jasińska', 'jwn@wp.pl', '742834222', 'Filarskiego 13/42');
INSERT INTO kierowcy VALUES (42, '61101485277', 'Maksymilian', 'Grabowski', 'brygcwt@interia.pl', '558784926', 'Bierdzańska 61/18');
INSERT INTO kierowcy VALUES (43, '94053170771', 'Olaf', 'Rutkowski', 'ksoqwmlaqdw@gmail.com', '686063687', 'Wolna 93/60');
INSERT INTO kierowcy VALUES (44, '57061833052', 'Mikołaj', 'Maciejewski', 'cvccmfyxjk@interia.eu', '697396980', 'Spadzista 03/59');
INSERT INTO kierowcy VALUES (45, '89112760486', 'Blanka', 'Andrzejewska', 'bifchqmv@interia.eu', '810071879', 'Wojciecha Korfantego 37/95');
INSERT INTO kierowcy VALUES (46, '95060178480', 'Wiktoria', 'Pawłowska', 'ujqe@o2.pl', '538440623', 'Józefa Hallera 15/74');
INSERT INTO kierowcy VALUES (47, '99042936707', 'Hanna', 'Mazur', 'tllnwbtxg@wp.pl', '847701093', 'Świętokrzyska 79/96');
INSERT INTO kierowcy VALUES (48, '81112652390', 'Tomasz', 'Gajewski', 'jkamezsx@gmail.com', '567100057', 'Przemyska 47/77');
INSERT INTO kierowcy VALUES (49, '52122573766', 'łucja', 'Mazurek', 'mgqqglpy@gmail.com', '626729290', 'Dr. Wojciecha Czerwińskiego 88/67');
INSERT INTO kierowcy VALUES (50, '48041599501', 'Paulina', 'Czerwińska', 'wxreigeob@interia.pl', '550970068', 'Alfreda Liczbańskiego 57/03');
INSERT INTO kierowcy VALUES (51, '13033003690', 'Bartłomiej', 'Borkowski', 'qhfyltzwvk@o2.pl', '846907976', 'Pl. Polonii Amerykańskiej 07/46');
INSERT INTO kierowcy VALUES (52, '17123098135', 'Mateusz', 'Andrzejewski', 'qfmsbhet@interia.eu', '743312073', 'Ks. Bolka Ligudy 70/12');
INSERT INTO kierowcy VALUES (53, '45023149954', 'Olaf', 'Piotrowski', 'ugyxncryf@interia.pl', '844063310', 'Os. Tuwima 55/30');
INSERT INTO kierowcy VALUES (54, '73021512548', 'Patrycja', 'Czerwińska', 'rcyuvy@interia.eu', '703801235', 'Nałkowskiej 90/94');
INSERT INTO kierowcy VALUES (55, '75080421643', 'Wiktoria', 'Woźniak', 'bmvbiqald@gmail.com', '532355826', 'Litewska 32/89');
INSERT INTO kierowcy VALUES (56, '21030181574', 'Tymoteusz', 'Konieczny', 'gsgzsreqn@gmail.com', '753335248', 'Nadrzeczna 27/66');
INSERT INTO kierowcy VALUES (57, '49040928017', 'Mikołaj', 'Adamczyk', 'vyqoeie@wp.pl', '798743184', 'Gwarków 33/21');
INSERT INTO kierowcy VALUES (58, '73071471079', 'Hubert', 'Marciniak', 'cqmruuvgwku@o2.pl', '725581815', 'Os. Akacjowe 68/13');
INSERT INTO kierowcy VALUES (59, '90022866087', 'Klaudia', 'Sikora', 'dprjobg@wp.pl', '543327352', 'Al. Dębowa 21/55');
INSERT INTO kierowcy VALUES (60, '35013104131', 'Alan', 'Szewczyk', 'cuenihvcnxu@wp.pl', '891915343', 'Bogusławskiego 98/39');
INSERT INTO kierowcy VALUES (61, '47020537220', 'Anna', 'Wróblewska', 'qzetocptd@wp.pl', '729256565', 'Małe Winiary 14/00');
INSERT INTO kierowcy VALUES (62, '97102879106', 'Oliwia', 'Jakubowska', 'hfulwpqiu@interia.pl', '828196749', 'Wincentego Kadłubka 49/74');
INSERT INTO kierowcy VALUES (63, '75122077672', 'Leon', 'Kalinowski', 'qlggcoczg@interia.eu', '611207164', 'Młyńska Góra 38/20');
INSERT INTO kierowcy VALUES (64, '22070292132', 'Krystian', 'Bąk', 'oae@interia.eu', '512266588', 'Bełk 24/75');
INSERT INTO kierowcy VALUES (65, '77101400583', 'Milena', 'Wróblewska', 'zltbbuhfyms@gmail.com', '580365714', 'Muzealna 11/33');
INSERT INTO kierowcy VALUES (66, '66111661741', 'Aleksandra', 'Witkowska', 'bmb@o2.pl', '651071229', 'Piotra Poliwody 90/43');
INSERT INTO kierowcy VALUES (67, '76010942553', 'Oliwier', 'Borkowski', 'qyom@gmail.com', '776727718', 'Zatorze 40/23');
INSERT INTO kierowcy VALUES (68, '26022664523', 'Małgorzata', 'Lewandowska', 'qqdiqtutujg@gmail.com', '875467081', 'Oleska 07/56');
INSERT INTO kierowcy VALUES (69, '52080714485', 'Zuzanna', 'Wiśniewska', 'ajjufs@interia.pl', '633481109', 'Spółdzielców 60/31');
INSERT INTO kierowcy VALUES (70, '17050602205', 'Kaja', 'Zawadzka', 'tdqczxx@wp.pl', '746648957', 'Sieradzka 37/97');
INSERT INTO kierowcy VALUES (71, '26040410364', 'Blanka', 'Mazur', 'iownntk@interia.pl', '542010280', 'Strzelców Bytomskich 19/68');
INSERT INTO kierowcy VALUES (72, '55101067854', 'Sebastian', 'Sikorski', 'jmjybeir@gmail.com', '601025824', 'Brata Ferdynanda Fludera 23/09');
INSERT INTO kierowcy VALUES (73, '15101682882', 'Hanna', 'Dąbrowska', 'goi@wp.pl', '823533838', 'Gosławicka 30/85');
INSERT INTO kierowcy VALUES (74, '73080723369', 'Kaja', 'Jakubowska', 'dyu@interia.pl', '816761014', 'Chróścińska 20/45');
INSERT INTO kierowcy VALUES (75, '46082971337', 'Maciej', 'Cieślak', 'icqxhotv@wp.pl', '520033299', 'Blok 15/37');
INSERT INTO kierowcy VALUES (76, '19061109133', 'Karol', 'Kwiatkowski', 'ffi@interia.eu', '836788783', 'Koziołka 24/18');
INSERT INTO kierowcy VALUES (77, '18091892046', 'Anna', 'Dudek', 'fwdobiyqc@gmail.com', '718206739', 'Stanisława Wasylewskiego 69/15');
INSERT INTO kierowcy VALUES (78, '88120851876', 'Olaf', 'Witkowski', 'ipfrpvv@interia.pl', '841940691', 'Ks. Prał. Bolesława Bilińskiego Prałata 60/33');
INSERT INTO kierowcy VALUES (79, '91110824084', 'Marta', 'Mazur', 'osghhdc@gmail.com', '548988781', 'Środkowa 64/39');
INSERT INTO kierowcy VALUES (80, '57042351843', 'Maja', 'Kubiak', 'cqzlycp@interia.eu', '775174857', 'Leszczynowa 11/22');
INSERT INTO kierowcy VALUES (81, '89060891739', 'Stanisław', 'Szymański', 'iqltq@interia.pl', '572723484', 'Joanny Żubr 63/39');
INSERT INTO kierowcy VALUES (82, '66060103453', 'Wiktor', 'Przybylski', 'dnz@interia.eu', '547344719', 'Kozłowicka 59/77');
INSERT INTO kierowcy VALUES (83, '60081185199', 'Adam', 'Mazurek', 'xoo@wp.pl', '559395141', 'Średnia 22/85');
INSERT INTO kierowcy VALUES (84, '28093135032', 'Bartosz', 'Zawadzki', 'xeujdiztc@interia.eu', '501336420', 'Spadzista 15/01');
INSERT INTO kierowcy VALUES (85, '79090475795', 'Mateusz', 'Michalski', 'qtrbtkd@wp.pl', '635683113', 'Jana Edmunda Osmańczyka 40/15');
INSERT INTO kierowcy VALUES (86, '42082087175', 'Alan', 'Szymański', 'ltzm@wp.pl', '831298973', 'Al. Spokojna 86/34');
INSERT INTO kierowcy VALUES (87, '37101679185', 'Blanka', 'Grabowska', 'wehhziv@gmail.com', '729839913', 'Limby 19/76');
INSERT INTO kierowcy VALUES (88, '54022165027', 'Joanna', 'Kaczmarczyk', 'zblicwdss@interia.eu', '601624155', 'Wileńska 43/18');
INSERT INTO kierowcy VALUES (89, '60050661352', 'Krystian', 'Chmielewski', 'bmkxrerlzni@gmail.com', '647790133', 'Odrzańska 63/83');
INSERT INTO kierowcy VALUES (90, '90022548693', 'Adam', 'Woźniak', 'vywg@o2.pl', '664103025', 'Al. Ks. Józefa Kentenicha 78/53');
INSERT INTO kierowcy VALUES (91, '85092648389', 'Nadia', 'Baran', 'uycswyavk@o2.pl', '691993440', 'Augustyna Kośnego 05/97');
INSERT INTO kierowcy VALUES (92, '60101278641', 'Weronika', 'Sobczak', 'rlxslu@interia.pl', '585876130', 'Bpa. Franciszka Cedzicha 02/99');
INSERT INTO kierowcy VALUES (93, '35082075028', 'Lilianna', 'Kaczmarczyk', 'ifm@o2.pl', '876544043', 'Daszyńskiego 79/11');
INSERT INTO kierowcy VALUES (94, '83081655156', 'Kacper', 'Włodarczyk', 'qqfryld@wp.pl', '795251497', 'Posiłkowa 66/40');
INSERT INTO kierowcy VALUES (95, '79082367350', 'Ksawery', 'Nowakowski', 'tesl@interia.eu', '621218661', 'Pionierska 78/56');
INSERT INTO kierowcy VALUES (96, '71030503346', 'Hanna', 'Błaszczyk', 'torps@interia.eu', '587891299', 'Jana Augustyna 12/89');
INSERT INTO kierowcy VALUES (97, '54010892733', 'Jan', 'Duda', 'wdokvfefh@wp.pl', '730459560', 'Gen. Grota Roweckiego 62/92');
INSERT INTO kierowcy VALUES (98, '22110190642', 'Pola', 'Kaczmarek', 'ysrdywmar@o2.pl', '791669847', 'Górka 39/27');
INSERT INTO kierowcy VALUES (99, '64040931054', 'Olaf', 'Wróblewski', 'stfrhfkx@wp.pl', '676984567', 'Nowodworska 79/73');
INSERT INTO kierowcy VALUES (100, '34021201742', 'Hanna', 'Mazurek', 'nha@interia.eu', '682331942', 'Stanisława Wasylewskiego 20/22');
INSERT INTO egzaminatorzy VALUES (1, 'Barbara', 'Kwiatkowska');
INSERT INTO egzaminatorzy VALUES (2, 'Tymon', 'Wiśniewski');
INSERT INTO egzaminatorzy VALUES (3, 'Oliwia', 'Jasińska');
INSERT INTO egzaminatorzy VALUES (4, 'Fabian', 'Krawczyk');
INSERT INTO egzaminatorzy VALUES (5, 'Blanka', 'Adamska');
INSERT INTO egzaminatorzy VALUES (6, 'Gabriela', 'Tomaszewska');
INSERT INTO egzaminatorzy VALUES (7, 'Klaudia', 'Sadowska');
INSERT INTO egzaminatorzy VALUES (8, 'Marcelina', 'Maciejewska');
INSERT INTO egzaminatorzy VALUES (9, 'Krzysztof', 'Mróz');
INSERT INTO egzaminatorzy VALUES (10, 'Dominik', 'Sikorski');
INSERT INTO egzaminatorzy VALUES (11, 'Gabriel', 'Zawadzki');
INSERT INTO egzaminatorzy VALUES (12, 'Sebastian', 'Zając');
INSERT INTO egzaminatorzy VALUES (13, 'Tomasz', 'Ostrowski');
INSERT INTO egzaminatorzy VALUES (14, 'Jagoda', 'Kołodziej');
INSERT INTO egzaminatorzy VALUES (15, 'Bartłomiej', 'Górski');
INSERT INTO egzaminatorzy VALUES (16, 'Bartłomiej', 'Adamczyk');
INSERT INTO egzaminatorzy VALUES (17, 'Emilia', 'Nowicka');
INSERT INTO egzaminatorzy VALUES (18, 'Stanisław', 'Sikora');
INSERT INTO egzaminatorzy VALUES (19, 'Katarzyna', 'Dąbrowska');
INSERT INTO egzaminatorzy VALUES (20, 'Nadia', 'Zając');
INSERT INTO egzaminatorzy VALUES (21, 'Bartłomiej', 'Chmielewski');
INSERT INTO egzaminatorzy VALUES (22, 'Oskar', 'Kowalski');
INSERT INTO egzaminatorzy VALUES (23, 'Maria', 'Jankowska');
INSERT INTO egzaminatorzy VALUES (24, 'Patrycja', 'Makowska');
INSERT INTO egzaminatorzy VALUES (25, 'Wiktoria', 'Kwiatkowska');
INSERT INTO egzaminatorzy VALUES (26, 'Paulina', 'Zawadzka');
INSERT INTO egzaminatorzy VALUES (27, 'Ignacy', 'Dudek');
INSERT INTO egzaminatorzy VALUES (28, 'Liliana', 'Krawczyk');
INSERT INTO egzaminatorzy VALUES (29, 'Laura', 'Czarnecka');
INSERT INTO egzaminatorzy VALUES (30, 'Klaudia', 'Sadowska');
INSERT INTO egzaminatorzy VALUES (31, 'Antonina', 'Ostrowska');
INSERT INTO egzaminatorzy VALUES (32, 'Blanka', 'Baran');
INSERT INTO egzaminatorzy VALUES (33, 'Gabriel', 'Król');
INSERT INTO egzaminatorzy VALUES (34, 'Dominika', 'Jankowska');
INSERT INTO egzaminatorzy VALUES (35, 'Mikołaj', 'Mróz');
INSERT INTO egzaminatorzy VALUES (36, 'Nikola', 'Maciejewska');
INSERT INTO egzaminatorzy VALUES (37, 'Helena', 'Pawlak');
INSERT INTO egzaminatorzy VALUES (38, 'Gabriela', 'Piotrowska');
INSERT INTO egzaminatorzy VALUES (39, 'Martyna', 'Mazur');
INSERT INTO egzaminatorzy VALUES (40, 'Mikołaj', 'Krawczyk');
INSERT INTO egzaminatorzy VALUES (41, 'Tomasz', 'Marciniak');
INSERT INTO egzaminatorzy VALUES (42, 'Natan', 'Sobczak');
INSERT INTO egzaminatorzy VALUES (43, 'Dominik', 'Sokołowski');
INSERT INTO egzaminatorzy VALUES (44, 'łucja', 'Chmielewska');
INSERT INTO egzaminatorzy VALUES (45, 'Maria', 'Zając');
INSERT INTO egzaminatorzy VALUES (46, 'Antonina', 'Zawadzka');
INSERT INTO egzaminatorzy VALUES (47, 'Jakub', 'Mazurek');
INSERT INTO egzaminatorzy VALUES (48, 'Pola', 'Zielińska');
INSERT INTO egzaminatorzy VALUES (49, 'Filip', 'Chmielewski');
INSERT INTO egzaminatorzy VALUES (50, 'Milena', 'Makowska');
INSERT INTO egzaminatorzy VALUES (51, 'Ignacy', 'Szulc');
INSERT INTO egzaminatorzy VALUES (52, 'Szymon', 'Pietrzak');
INSERT INTO egzaminatorzy VALUES (53, 'Mateusz', 'Szczepański');
INSERT INTO egzaminatorzy VALUES (54, 'Anna', 'Ostrowska');
INSERT INTO egzaminatorzy VALUES (55, 'Katarzyna', 'Kalinowska');
INSERT INTO egzaminatorzy VALUES (56, 'Kajetan', 'Zawadzki');
INSERT INTO egzaminatorzy VALUES (57, 'Tomasz', 'Sadowski');
INSERT INTO egzaminatorzy VALUES (58, 'Tomasz', 'Jasiński');
INSERT INTO egzaminatorzy VALUES (59, 'Piotr', 'Jankowski');
INSERT INTO egzaminatorzy VALUES (60, 'Amelia', 'Wiśniewska');
INSERT INTO egzaminatorzy VALUES (61, 'Krzysztof', 'Adamczyk');
INSERT INTO egzaminatorzy VALUES (62, 'Hubert', 'Olszewski');
INSERT INTO egzaminatorzy VALUES (63, 'Lena', 'Krawczyk');
INSERT INTO egzaminatorzy VALUES (64, 'Maksymilian', 'Błaszczyk');
INSERT INTO ośrodki VALUES (1, 'tymczasowy osrodek1', 'Hibnera 47/69');
INSERT INTO ośrodki VALUES (2, 'tymczasowy osrodek2', 'Gminna 15/68');
INSERT INTO ośrodki VALUES (3, 'tymczasowy osrodek3', 'Jurija Gagarina 59/23');
INSERT INTO ośrodki VALUES (4, 'tymczasowy osrodek4', 'Mikołaja Goltberga 87/53');
INSERT INTO ośrodki VALUES (5, 'tymczasowy osrodek5', 'Młyńska Góra 54/49');
INSERT INTO ośrodki VALUES (6, 'tymczasowy osrodek6', 'Jana Stanisława Jankowskiego 85/94');
INSERT INTO ośrodki VALUES (7, 'tymczasowy osrodek7', 'Leśny Dwór 80/34');
INSERT INTO ośrodki VALUES (8, 'tymczasowy osrodek8', 'Wojciecha Korfantego 07/76');
INSERT INTO ośrodki VALUES (9, 'tymczasowy osrodek9', 'Krawiecka 11/75');
INSERT INTO ośrodki VALUES (10, 'tymczasowy osrodek10', 'Ks. Scheitzy 05/36');
INSERT INTO ośrodki VALUES (11, 'tymczasowy osrodek11', 'Apostoły 61/42');
INSERT INTO ośrodki VALUES (12, 'tymczasowy osrodek12', 'Zielona 10/72');
INSERT INTO ośrodki VALUES (13, 'tymczasowy osrodek13', 'Konarskiego 20/77');
INSERT INTO ośrodki VALUES (14, 'tymczasowy osrodek14', 'Józefa Hallera 77/46');
INSERT INTO ośrodki VALUES (15, 'tymczasowy osrodek15', 'Fornalskiej 29/69');
INSERT INTO ośrodki VALUES (16, 'tymczasowy osrodek16', 'Czesława Janczarskiego 21/06');
INSERT INTO mandaty_wystawiający VALUES (1, 'Kamil', 'Nowakowski');
INSERT INTO mandaty_wystawiający VALUES (2, 'Helena', 'Makowska');
INSERT INTO mandaty_wystawiający VALUES (3, 'Liliana', 'Nowicka');
INSERT INTO mandaty_wystawiający VALUES (4, 'Dominik', 'Jabłoński');
INSERT INTO mandaty_wystawiający VALUES (5, 'Magdalena', 'Urbańska');
INSERT INTO mandaty_wystawiający VALUES (6, 'Kacper', 'Wilk');
INSERT INTO mandaty_wystawiający VALUES (7, 'Kajetan', 'Wysocki');
INSERT INTO mandaty_wystawiający VALUES (8, 'łucja', 'Majewska');
INSERT INTO mandaty_wystawiający VALUES (9, 'Igor', 'Baran');
INSERT INTO mandaty_wystawiający VALUES (10, 'Kamil', 'Laskowski');
INSERT INTO mandaty_wystawiający VALUES (11, 'Hubert', 'Wysocki');
INSERT INTO mandaty_wystawiający VALUES (12, 'Marcelina', 'Górska');
INSERT INTO mandaty_wystawiający VALUES (13, 'Jan', 'Krawczyk');
INSERT INTO mandaty_wystawiający VALUES (14, 'Helena', 'Zakrzewska');
INSERT INTO mandaty_wystawiający VALUES (15, 'Jagoda', 'Lis');
INSERT INTO mandaty_wystawiający VALUES (16, 'Natan', 'Ostrowski');
INSERT INTO wykroczenia VALUES (1, 'wykroczenie bylo bylo', 352, 6);
INSERT INTO wykroczenia VALUES (2, 'wykroczenie bylo bylo', 243, 5);
INSERT INTO wykroczenia VALUES (3, 'a to juz wgl niedopuszczalne!', 515, 4);
INSERT INTO wykroczenia VALUES (4, 'a to juz wgl niedopuszczalne!', 747, 5);
INSERT INTO wykroczenia VALUES (5, 'wykroczenie bylo bylo', 570, 1);
INSERT INTO wykroczenia VALUES (6, 'a to juz wgl niedopuszczalne!', 550, 8);
INSERT INTO wykroczenia VALUES (7, 'wykroczenie bylo bylo', 592, 10);
INSERT INTO wykroczenia VALUES (8, 'wykroczenie bylo bylo', 110, 5);
INSERT INTO wykroczenia VALUES (9, 'wykroczenie bylo bylo', 297, 10);
INSERT INTO wykroczenia VALUES (10, 'a to juz wgl niedopuszczalne!', 809, 8);
INSERT INTO wykroczenia VALUES (11, 'a to juz wgl niedopuszczalne!', 169, 8);
INSERT INTO wykroczenia VALUES (12, 'wykroczenie bylo bylo', 336, 5);
INSERT INTO wykroczenia VALUES (13, 'a to juz wgl niedopuszczalne!', 332, 8);
INSERT INTO wykroczenia VALUES (14, 'wykroczenie bylo bylo', 521, 7);
INSERT INTO wykroczenia VALUES (15, 'wykroczenie bylo bylo', 841, 6);
INSERT INTO wykroczenia VALUES (16, 'wykroczenie bylo bylo', 942, 9);
INSERT INTO wykroczenia VALUES (17, 'wykroczenie bylo bylo', 944, 7);
INSERT INTO wykroczenia VALUES (18, 'wykroczenie bylo bylo', 556, 2);
INSERT INTO wykroczenia VALUES (19, 'a to juz wgl niedopuszczalne!', 223, 4);
INSERT INTO wykroczenia VALUES (20, 'wykroczenie bylo bylo', 517, 2);
INSERT INTO wykroczenia VALUES (21, 'a to juz wgl niedopuszczalne!', 225, 1);
INSERT INTO wykroczenia VALUES (22, 'wykroczenie bylo bylo', 116, 5);
INSERT INTO wykroczenia VALUES (23, 'wykroczenie bylo bylo', 784, 2);
INSERT INTO wykroczenia VALUES (24, 'a to juz wgl niedopuszczalne!', 720, 1);
INSERT INTO wykroczenia VALUES (25, 'wykroczenie bylo bylo', 740, 9);
INSERT INTO wykroczenia VALUES (26, 'a to juz wgl niedopuszczalne!', 842, 5);
INSERT INTO wykroczenia VALUES (27, 'a to juz wgl niedopuszczalne!', 350, 2);
INSERT INTO wykroczenia VALUES (28, 'wykroczenie bylo bylo', 605, 10);
INSERT INTO wykroczenia VALUES (29, 'a to juz wgl niedopuszczalne!', 791, 9);
INSERT INTO wykroczenia VALUES (30, 'wykroczenie bylo bylo', 707, 8);
INSERT INTO wykroczenia VALUES (31, 'wykroczenie bylo bylo', 124, 7);
INSERT INTO wykroczenia VALUES (32, 'a to juz wgl niedopuszczalne!', 585, 1);
INSERT INTO wykroczenia VALUES (33, 'a to juz wgl niedopuszczalne!', 961, 5);
INSERT INTO wykroczenia VALUES (34, 'a to juz wgl niedopuszczalne!', 910, 4);
INSERT INTO wykroczenia VALUES (35, 'a to juz wgl niedopuszczalne!', 83, 2);
INSERT INTO wykroczenia VALUES (36, 'a to juz wgl niedopuszczalne!', 303, 10);
INSERT INTO wykroczenia VALUES (37, 'wykroczenie bylo bylo', 694, 10);
INSERT INTO wykroczenia VALUES (38, 'wykroczenie bylo bylo', 210, 5);
INSERT INTO wykroczenia VALUES (39, 'wykroczenie bylo bylo', 528, 4);
INSERT INTO wykroczenia VALUES (40, 'wykroczenie bylo bylo', 453, 2);
INSERT INTO wykroczenia VALUES (41, 'a to juz wgl niedopuszczalne!', 688, 4);
INSERT INTO wykroczenia VALUES (42, 'a to juz wgl niedopuszczalne!', 627, 2);
INSERT INTO wykroczenia VALUES (43, 'a to juz wgl niedopuszczalne!', 455, 10);
INSERT INTO wykroczenia VALUES (44, 'a to juz wgl niedopuszczalne!', 380, 9);
INSERT INTO wykroczenia VALUES (45, 'a to juz wgl niedopuszczalne!', 579, 6);
INSERT INTO wykroczenia VALUES (46, 'a to juz wgl niedopuszczalne!', 663, 8);
INSERT INTO wykroczenia VALUES (47, 'wykroczenie bylo bylo', 498, 8);
INSERT INTO wykroczenia VALUES (48, 'wykroczenie bylo bylo', 476, 9);
INSERT INTO wykroczenia VALUES (49, 'wykroczenie bylo bylo', 720, 1);
INSERT INTO wykroczenia VALUES (50, 'a to juz wgl niedopuszczalne!', 534, 6);
INSERT INTO wykroczenia VALUES (51, 'wykroczenie bylo bylo', 456, 8);
INSERT INTO wykroczenia VALUES (52, 'wykroczenie bylo bylo', 867, 2);
INSERT INTO wykroczenia VALUES (53, 'wykroczenie bylo bylo', 291, 3);
INSERT INTO wykroczenia VALUES (54, 'wykroczenie bylo bylo', 595, 10);
INSERT INTO wykroczenia VALUES (55, 'wykroczenie bylo bylo', 938, 8);
INSERT INTO wykroczenia VALUES (56, 'wykroczenie bylo bylo', 787, 10);
INSERT INTO wykroczenia VALUES (57, 'a to juz wgl niedopuszczalne!', 593, 2);
INSERT INTO wykroczenia VALUES (58, 'wykroczenie bylo bylo', 54, 7);
INSERT INTO wykroczenia VALUES (59, 'wykroczenie bylo bylo', 922, 1);
INSERT INTO wykroczenia VALUES (60, 'wykroczenie bylo bylo', 462, 10);
INSERT INTO wykroczenia VALUES (61, 'a to juz wgl niedopuszczalne!', 456, 1);
INSERT INTO wykroczenia VALUES (62, 'a to juz wgl niedopuszczalne!', 379, 10);
INSERT INTO wykroczenia VALUES (63, 'a to juz wgl niedopuszczalne!', 582, 10);
INSERT INTO wykroczenia VALUES (64, 'a to juz wgl niedopuszczalne!', 240, 4);
INSERT INTO wykroczenia VALUES (65, 'a to juz wgl niedopuszczalne!', 694, 1);
INSERT INTO wykroczenia VALUES (66, 'a to juz wgl niedopuszczalne!', 361, 5);
INSERT INTO wykroczenia VALUES (67, 'a to juz wgl niedopuszczalne!', 99, 4);
INSERT INTO wykroczenia VALUES (68, 'a to juz wgl niedopuszczalne!', 688, 10);
INSERT INTO wykroczenia VALUES (69, 'wykroczenie bylo bylo', 382, 10);
INSERT INTO wykroczenia VALUES (70, 'a to juz wgl niedopuszczalne!', 917, 9);
INSERT INTO wykroczenia VALUES (71, 'wykroczenie bylo bylo', 208, 9);
INSERT INTO wykroczenia VALUES (72, 'a to juz wgl niedopuszczalne!', 950, 3);
INSERT INTO wykroczenia VALUES (73, 'wykroczenie bylo bylo', 338, 4);
INSERT INTO wykroczenia VALUES (74, 'a to juz wgl niedopuszczalne!', 333, 6);
INSERT INTO wykroczenia VALUES (75, 'a to juz wgl niedopuszczalne!', 162, 10);
INSERT INTO wykroczenia VALUES (76, 'a to juz wgl niedopuszczalne!', 850, 10);
INSERT INTO wykroczenia VALUES (77, 'wykroczenie bylo bylo', 479, 8);
INSERT INTO wykroczenia VALUES (78, 'wykroczenie bylo bylo', 215, 4);
INSERT INTO wykroczenia VALUES (79, 'wykroczenie bylo bylo', 607, 9);
INSERT INTO wykroczenia VALUES (80, 'a to juz wgl niedopuszczalne!', 155, 5);
INSERT INTO wykroczenia VALUES (81, 'a to juz wgl niedopuszczalne!', 309, 4);
INSERT INTO wykroczenia VALUES (82, 'a to juz wgl niedopuszczalne!', 520, 10);
INSERT INTO wykroczenia VALUES (83, 'wykroczenie bylo bylo', 759, 1);
INSERT INTO wykroczenia VALUES (84, 'a to juz wgl niedopuszczalne!', 671, 6);
INSERT INTO wykroczenia VALUES (85, 'wykroczenie bylo bylo', 260, 3);
INSERT INTO wykroczenia VALUES (86, 'a to juz wgl niedopuszczalne!', 723, 1);
INSERT INTO wykroczenia VALUES (87, 'a to juz wgl niedopuszczalne!', 693, 2);
INSERT INTO wykroczenia VALUES (88, 'a to juz wgl niedopuszczalne!', 800, 2);
INSERT INTO wykroczenia VALUES (89, 'a to juz wgl niedopuszczalne!', 257, 6);
INSERT INTO wykroczenia VALUES (90, 'a to juz wgl niedopuszczalne!', 305, 5);
INSERT INTO wykroczenia VALUES (91, 'a to juz wgl niedopuszczalne!', 247, 3);
INSERT INTO wykroczenia VALUES (92, 'wykroczenie bylo bylo', 864, 6);
INSERT INTO wykroczenia VALUES (93, 'a to juz wgl niedopuszczalne!', 317, 3);
INSERT INTO wykroczenia VALUES (94, 'wykroczenie bylo bylo', 604, 3);
INSERT INTO wykroczenia VALUES (95, 'wykroczenie bylo bylo', 395, 3);
INSERT INTO wykroczenia VALUES (96, 'a to juz wgl niedopuszczalne!', 769, 8);
INSERT INTO wykroczenia VALUES (97, 'wykroczenie bylo bylo', 920, 6);
INSERT INTO wykroczenia VALUES (98, 'a to juz wgl niedopuszczalne!', 250, 7);
INSERT INTO wykroczenia VALUES (99, 'wykroczenie bylo bylo', 472, 2);
INSERT INTO wykroczenia VALUES (100, 'a to juz wgl niedopuszczalne!', 1016, 9);
INSERT INTO wykroczenia VALUES (101, 'wykroczenie bylo bylo', 916, 4);
INSERT INTO wykroczenia VALUES (102, 'wykroczenie bylo bylo', 683, 6);
INSERT INTO wykroczenia VALUES (103, 'a to juz wgl niedopuszczalne!', 964, 10);
INSERT INTO wykroczenia VALUES (104, 'wykroczenie bylo bylo', 772, 7);
INSERT INTO wykroczenia VALUES (105, 'a to juz wgl niedopuszczalne!', 264, 5);
INSERT INTO wykroczenia VALUES (106, 'wykroczenie bylo bylo', 213, 1);
INSERT INTO wykroczenia VALUES (107, 'a to juz wgl niedopuszczalne!', 442, 7);
INSERT INTO wykroczenia VALUES (108, 'a to juz wgl niedopuszczalne!', 829, 7);
INSERT INTO wykroczenia VALUES (109, 'a to juz wgl niedopuszczalne!', 579, 5);
INSERT INTO wykroczenia VALUES (110, 'wykroczenie bylo bylo', 631, 7);
INSERT INTO wykroczenia VALUES (111, 'wykroczenie bylo bylo', 455, 6);
INSERT INTO wykroczenia VALUES (112, 'a to juz wgl niedopuszczalne!', 904, 5);
INSERT INTO wykroczenia VALUES (113, 'a to juz wgl niedopuszczalne!', 491, 3);
INSERT INTO wykroczenia VALUES (114, 'wykroczenie bylo bylo', 327, 8);
INSERT INTO wykroczenia VALUES (115, 'a to juz wgl niedopuszczalne!', 89, 4);
INSERT INTO wykroczenia VALUES (116, 'wykroczenie bylo bylo', 594, 2);
INSERT INTO wykroczenia VALUES (117, 'a to juz wgl niedopuszczalne!', 867, 5);
INSERT INTO wykroczenia VALUES (118, 'wykroczenie bylo bylo', 300, 9);
INSERT INTO wykroczenia VALUES (119, 'wykroczenie bylo bylo', 886, 10);
INSERT INTO wykroczenia VALUES (120, 'wykroczenie bylo bylo', 951, 6);
INSERT INTO wykroczenia VALUES (121, 'wykroczenie bylo bylo', 213, 3);
INSERT INTO wykroczenia VALUES (122, 'a to juz wgl niedopuszczalne!', 452, 1);
INSERT INTO wykroczenia VALUES (123, 'wykroczenie bylo bylo', 546, 5);
INSERT INTO wykroczenia VALUES (124, 'a to juz wgl niedopuszczalne!', 193, 1);
INSERT INTO wykroczenia VALUES (125, 'wykroczenie bylo bylo', 149, 6);
INSERT INTO wykroczenia VALUES (126, 'a to juz wgl niedopuszczalne!', 880, 4);
INSERT INTO wykroczenia VALUES (127, 'wykroczenie bylo bylo', 537, 9);
INSERT INTO wykroczenia VALUES (128, 'wykroczenie bylo bylo', 594, 1);
INSERT INTO mandaty VALUES (1, 58, 13, 57);
INSERT INTO mandaty VALUES (2, 61, 13, 77);
INSERT INTO mandaty VALUES (3, 19, 8, 39);
INSERT INTO mandaty VALUES (4, 75, 8, 81);
INSERT INTO mandaty VALUES (5, 60, 4, 93);
INSERT INTO mandaty VALUES (6, 26, 7, 54);
INSERT INTO mandaty VALUES (7, 96, 13, 99);
INSERT INTO mandaty VALUES (8, 99, 11, 60);
INSERT INTO mandaty VALUES (9, 66, 3, 87);
INSERT INTO mandaty VALUES (10, 88, 9, 30);
INSERT INTO mandaty VALUES (11, 42, 14, 26);
INSERT INTO mandaty VALUES (12, 34, 7, 6);
INSERT INTO mandaty VALUES (13, 63, 13, 125);
INSERT INTO mandaty VALUES (14, 45, 11, 36);
INSERT INTO mandaty VALUES (15, 37, 7, 119);
INSERT INTO mandaty VALUES (16, 53, 12, 45);
INSERT INTO mandaty VALUES (17, 2, 4, 90);
INSERT INTO mandaty VALUES (18, 24, 14, 4);
INSERT INTO mandaty VALUES (19, 27, 7, 22);
INSERT INTO mandaty VALUES (20, 86, 10, 14);
INSERT INTO mandaty VALUES (21, 75, 12, 59);
INSERT INTO mandaty VALUES (22, 40, 5, 97);
INSERT INTO mandaty VALUES (23, 57, 11, 125);
INSERT INTO mandaty VALUES (24, 33, 7, 88);
INSERT INTO mandaty VALUES (25, 80, 4, 30);
INSERT INTO mandaty VALUES (26, 59, 12, 9);
INSERT INTO mandaty VALUES (27, 55, 10, 28);
INSERT INTO mandaty VALUES (28, 4, 9, 10);
INSERT INTO mandaty VALUES (29, 51, 4, 96);
INSERT INTO mandaty VALUES (30, 96, 5, 10);
INSERT INTO mandaty VALUES (31, 21, 3, 53);
INSERT INTO mandaty VALUES (32, 32, 10, 25);
INSERT INTO mandaty VALUES (33, 92, 6, 4);
INSERT INTO mandaty VALUES (34, 69, 14, 26);
INSERT INTO mandaty VALUES (35, 36, 9, 45);
INSERT INTO mandaty VALUES (36, 57, 11, 25);
INSERT INTO mandaty VALUES (37, 57, 10, 18);
INSERT INTO mandaty VALUES (38, 85, 1, 122);
INSERT INTO mandaty VALUES (39, 86, 12, 13);
INSERT INTO mandaty VALUES (40, 77, 11, 33);
INSERT INTO mandaty VALUES (41, 50, 8, 83);
INSERT INTO mandaty VALUES (42, 42, 15, 60);
INSERT INTO mandaty VALUES (43, 43, 6, 97);
INSERT INTO mandaty VALUES (44, 62, 10, 62);
INSERT INTO mandaty VALUES (45, 95, 5, 119);
INSERT INTO mandaty VALUES (46, 84, 13, 1);
INSERT INTO mandaty VALUES (47, 76, 14, 10);
INSERT INTO mandaty VALUES (48, 29, 10, 107);
INSERT INTO mandaty VALUES (49, 62, 15, 38);
INSERT INTO mandaty VALUES (50, 7, 3, 80);
INSERT INTO mandaty VALUES (51, 47, 1, 119);
INSERT INTO mandaty VALUES (52, 10, 2, 85);
INSERT INTO mandaty VALUES (53, 33, 12, 75);
INSERT INTO mandaty VALUES (54, 74, 9, 84);
INSERT INTO mandaty VALUES (55, 15, 16, 73);
INSERT INTO mandaty VALUES (56, 37, 3, 69);
INSERT INTO mandaty VALUES (57, 98, 14, 82);
INSERT INTO mandaty VALUES (58, 51, 10, 11);
INSERT INTO mandaty VALUES (59, 53, 15, 121);
INSERT INTO mandaty VALUES (60, 54, 1, 124);
INSERT INTO mandaty VALUES (61, 98, 4, 28);
INSERT INTO mandaty VALUES (62, 8, 9, 13);
INSERT INTO mandaty VALUES (63, 17, 9, 105);
INSERT INTO mandaty VALUES (64, 15, 10, 49);
INSERT INTO mandaty VALUES (65, 22, 9, 128);
INSERT INTO mandaty VALUES (66, 74, 13, 2);
INSERT INTO mandaty VALUES (67, 31, 2, 79);
INSERT INTO mandaty VALUES (68, 48, 1, 120);
INSERT INTO mandaty VALUES (69, 59, 9, 119);
INSERT INTO mandaty VALUES (70, 3, 7, 87);
INSERT INTO mandaty VALUES (71, 6, 4, 58);
INSERT INTO mandaty VALUES (72, 69, 7, 114);
INSERT INTO mandaty VALUES (73, 34, 15, 59);
INSERT INTO mandaty VALUES (74, 94, 1, 116);
INSERT INTO mandaty VALUES (75, 10, 7, 92);
INSERT INTO mandaty VALUES (76, 30, 4, 105);
INSERT INTO mandaty VALUES (77, 87, 6, 26);
INSERT INTO mandaty VALUES (78, 58, 10, 122);
INSERT INTO mandaty VALUES (79, 21, 8, 115);
INSERT INTO mandaty VALUES (80, 39, 14, 41);
INSERT INTO mandaty VALUES (81, 22, 16, 108);
INSERT INTO mandaty VALUES (82, 63, 12, 50);
INSERT INTO mandaty VALUES (83, 25, 5, 81);
INSERT INTO mandaty VALUES (84, 91, 6, 17);
INSERT INTO mandaty VALUES (85, 34, 8, 71);
INSERT INTO mandaty VALUES (86, 22, 9, 59);
INSERT INTO mandaty VALUES (87, 42, 11, 48);
INSERT INTO mandaty VALUES (88, 39, 12, 121);
INSERT INTO mandaty VALUES (89, 69, 5, 32);
INSERT INTO mandaty VALUES (90, 35, 3, 30);
INSERT INTO mandaty VALUES (91, 39, 8, 109);
INSERT INTO mandaty VALUES (92, 30, 7, 40);
INSERT INTO mandaty VALUES (93, 19, 7, 93);
INSERT INTO mandaty VALUES (94, 19, 1, 114);
INSERT INTO mandaty VALUES (95, 48, 14, 25);
INSERT INTO mandaty VALUES (96, 26, 7, 81);
INSERT INTO mandaty VALUES (97, 80, 8, 28);
INSERT INTO mandaty VALUES (98, 92, 3, 71);
INSERT INTO mandaty VALUES (99, 56, 7, 75);
INSERT INTO mandaty VALUES (100, 36, 13, 30);
INSERT INTO mandaty VALUES (101, 33, 11, 21);
INSERT INTO mandaty VALUES (102, 5, 4, 107);
INSERT INTO mandaty VALUES (103, 20, 14, 17);
INSERT INTO mandaty VALUES (104, 64, 9, 65);
INSERT INTO mandaty VALUES (105, 30, 4, 111);
INSERT INTO mandaty VALUES (106, 26, 5, 117);
INSERT INTO mandaty VALUES (107, 35, 1, 61);
INSERT INTO mandaty VALUES (108, 90, 12, 95);
INSERT INTO mandaty VALUES (109, 52, 15, 85);
INSERT INTO mandaty VALUES (110, 91, 2, 17);
INSERT INTO mandaty VALUES (111, 48, 2, 59);
INSERT INTO mandaty VALUES (112, 92, 14, 62);
INSERT INTO mandaty VALUES (113, 39, 2, 75);
INSERT INTO mandaty VALUES (114, 63, 1, 51);
INSERT INTO mandaty VALUES (115, 8, 2, 6);
INSERT INTO mandaty VALUES (116, 6, 12, 11);
INSERT INTO mandaty VALUES (117, 30, 6, 123);
INSERT INTO mandaty VALUES (118, 26, 11, 6);
INSERT INTO mandaty VALUES (119, 28, 6, 36);
INSERT INTO mandaty VALUES (120, 8, 12, 118);
INSERT INTO mandaty VALUES (121, 100, 15, 23);
INSERT INTO mandaty VALUES (122, 94, 7, 117);
INSERT INTO mandaty VALUES (123, 67, 9, 54);
INSERT INTO mandaty VALUES (124, 94, 11, 54);
INSERT INTO mandaty VALUES (125, 40, 14, 104);
INSERT INTO mandaty VALUES (126, 2, 15, 99);
INSERT INTO mandaty VALUES (127, 60, 5, 120);
INSERT INTO mandaty VALUES (128, 42, 6, 66);
INSERT INTO egzaminy VALUES (1, '2005-10-29', 'teoria', 41, 3);
INSERT INTO egzaminy VALUES (2, '2005-09-29', 'teoria', 10, 7);
INSERT INTO egzaminy VALUES (3, '1976-09-01', 'praktyka', 42, 10);
INSERT INTO egzaminy VALUES (4, '1994-09-07', 'praktyka', 62, 6);
INSERT INTO egzaminy VALUES (5, '2011-01-14', 'teoria', 38, 15);
INSERT INTO egzaminy VALUES (6, '2003-04-12', 'teoria', 54, 13);
INSERT INTO egzaminy VALUES (7, '1988-08-27', 'teoria', 41, 2);
INSERT INTO egzaminy VALUES (8, '1995-06-08', 'praktyka', 16, 15);
INSERT INTO egzaminy VALUES (9, '1978-08-06', 'praktyka', 62, 13);
INSERT INTO egzaminy VALUES (10, '2006-03-18', 'praktyka', 14, 7);
INSERT INTO egzaminy VALUES (11, '2013-07-27', 'praktyka', 30, 8);
INSERT INTO egzaminy VALUES (12, '1997-07-09', 'praktyka', 24, 4);
INSERT INTO egzaminy VALUES (13, '1982-08-29', 'teoria', 15, 5);
INSERT INTO egzaminy VALUES (14, '1994-02-20', 'praktyka', 28, 5);
INSERT INTO egzaminy VALUES (15, '2014-03-15', 'praktyka', 19, 13);
INSERT INTO egzaminy VALUES (16, '1981-10-03', 'praktyka', 52, 12);
INSERT INTO egzaminy VALUES (17, '2014-02-28', 'praktyka', 24, 13);
INSERT INTO egzaminy VALUES (18, '1996-07-09', 'teoria', 12, 7);
INSERT INTO egzaminy VALUES (19, '1980-04-28', 'praktyka', 2, 12);
INSERT INTO egzaminy VALUES (20, '2008-05-28', 'teoria', 1, 1);
INSERT INTO egzaminy VALUES (21, '1994-04-12', 'teoria', 48, 5);
INSERT INTO egzaminy VALUES (22, '1979-04-02', 'teoria', 42, 13);
INSERT INTO egzaminy VALUES (23, '1997-07-25', 'praktyka', 40, 7);
INSERT INTO egzaminy VALUES (24, '1979-02-04', 'teoria', 26, 15);
INSERT INTO egzaminy VALUES (25, '2013-11-20', 'praktyka', 11, 8);
INSERT INTO egzaminy VALUES (26, '1987-06-07', 'teoria', 16, 7);
INSERT INTO egzaminy VALUES (27, '2000-04-30', 'praktyka', 62, 7);
INSERT INTO egzaminy VALUES (28, '1977-12-17', 'praktyka', 2, 12);
INSERT INTO egzaminy VALUES (29, '1985-02-05', 'teoria', 25, 11);
INSERT INTO egzaminy VALUES (30, '2013-04-05', 'teoria', 20, 7);
INSERT INTO egzaminy VALUES (31, '1987-04-03', 'teoria', 13, 4);
INSERT INTO egzaminy VALUES (32, '2008-06-29', 'praktyka', 4, 12);
INSERT INTO egzaminy VALUES (33, '1987-02-05', 'praktyka', 50, 8);
INSERT INTO egzaminy VALUES (34, '2002-05-15', 'praktyka', 52, 14);
INSERT INTO egzaminy VALUES (35, '2005-06-27', 'praktyka', 39, 16);
INSERT INTO egzaminy VALUES (36, '1976-04-09', 'teoria', 55, 3);
INSERT INTO egzaminy VALUES (37, '1999-12-26', 'praktyka', 54, 11);
INSERT INTO egzaminy VALUES (38, '2009-02-08', 'praktyka', 34, 9);
INSERT INTO egzaminy VALUES (39, '1999-09-11', 'praktyka', 9, 9);
INSERT INTO egzaminy VALUES (40, '1976-03-08', 'teoria', 18, 9);
INSERT INTO egzaminy VALUES (41, '1995-11-22', 'praktyka', 56, 10);
INSERT INTO egzaminy VALUES (42, '1995-04-03', 'teoria', 6, 6);
INSERT INTO egzaminy VALUES (43, '2004-04-09', 'praktyka', 33, 16);
INSERT INTO egzaminy VALUES (44, '1996-05-24', 'teoria', 21, 13);
INSERT INTO egzaminy VALUES (45, '1992-07-05', 'teoria', 20, 4);
INSERT INTO egzaminy VALUES (46, '1978-01-14', 'praktyka', 19, 13);
INSERT INTO egzaminy VALUES (47, '2006-08-06', 'teoria', 51, 2);
INSERT INTO egzaminy VALUES (48, '1995-01-01', 'praktyka', 53, 9);
INSERT INTO egzaminy VALUES (49, '2008-10-29', 'praktyka', 20, 14);
INSERT INTO egzaminy VALUES (50, '1983-01-08', 'teoria', 40, 7);
INSERT INTO egzaminy VALUES (51, '1997-11-11', 'praktyka', 1, 10);
INSERT INTO egzaminy VALUES (52, '1975-08-21', 'praktyka', 31, 3);
INSERT INTO egzaminy VALUES (53, '1988-03-27', 'teoria', 21, 16);
INSERT INTO egzaminy VALUES (54, '1997-02-15', 'praktyka', 59, 12);
INSERT INTO egzaminy VALUES (55, '1978-07-03', 'praktyka', 30, 8);
INSERT INTO egzaminy VALUES (56, '1980-01-15', 'teoria', 1, 11);
INSERT INTO egzaminy VALUES (57, '2011-01-09', 'praktyka', 29, 1);
INSERT INTO egzaminy VALUES (58, '1982-10-06', 'teoria', 64, 16);
INSERT INTO egzaminy VALUES (59, '2007-02-02', 'teoria', 52, 8);
INSERT INTO egzaminy VALUES (60, '2003-04-20', 'praktyka', 14, 8);
INSERT INTO egzaminy VALUES (61, '1987-07-02', 'praktyka', 63, 4);
INSERT INTO egzaminy VALUES (62, '1999-11-28', 'praktyka', 40, 1);
INSERT INTO egzaminy VALUES (63, '1994-03-06', 'praktyka', 32, 9);
INSERT INTO egzaminy VALUES (64, '1988-09-20', 'praktyka', 58, 10);
INSERT INTO egzaminy VALUES (65, '1976-02-07', 'teoria', 3, 14);
INSERT INTO egzaminy VALUES (66, '1977-03-07', 'teoria', 53, 7);
INSERT INTO egzaminy VALUES (67, '1983-01-05', 'teoria', 24, 8);
INSERT INTO egzaminy VALUES (68, '2002-11-08', 'teoria', 25, 14);
INSERT INTO egzaminy VALUES (69, '2004-02-24', 'teoria', 17, 15);
INSERT INTO egzaminy VALUES (70, '2011-10-18', 'praktyka', 13, 6);
INSERT INTO egzaminy VALUES (71, '1976-03-16', 'teoria', 4, 16);
INSERT INTO egzaminy VALUES (72, '2014-12-11', 'praktyka', 40, 4);
INSERT INTO egzaminy VALUES (73, '1998-03-02', 'teoria', 40, 14);
INSERT INTO egzaminy VALUES (74, '2001-06-19', 'teoria', 25, 11);
INSERT INTO egzaminy VALUES (75, '1996-01-09', 'praktyka', 1, 1);
INSERT INTO egzaminy VALUES (76, '1989-10-10', 'teoria', 44, 11);
INSERT INTO egzaminy VALUES (77, '1992-03-25', 'teoria', 59, 6);
INSERT INTO egzaminy VALUES (78, '1975-07-14', 'teoria', 8, 8);
INSERT INTO egzaminy VALUES (79, '1985-02-21', 'praktyka', 61, 16);
INSERT INTO egzaminy VALUES (80, '1996-05-18', 'teoria', 41, 4);
INSERT INTO egzaminy VALUES (81, '2010-02-01', 'teoria', 53, 6);
INSERT INTO egzaminy VALUES (82, '1989-04-30', 'teoria', 10, 9);
INSERT INTO egzaminy VALUES (83, '2010-08-30', 'praktyka', 3, 15);
INSERT INTO egzaminy VALUES (84, '2001-12-15', 'praktyka', 44, 15);
INSERT INTO egzaminy VALUES (85, '1980-05-23', 'praktyka', 15, 15);
INSERT INTO egzaminy VALUES (86, '1979-02-11', 'praktyka', 31, 13);
INSERT INTO egzaminy VALUES (87, '1994-01-18', 'praktyka', 16, 6);
INSERT INTO egzaminy VALUES (88, '1989-07-21', 'praktyka', 3, 4);
INSERT INTO egzaminy VALUES (89, '1995-01-29', 'teoria', 44, 11);
INSERT INTO egzaminy VALUES (90, '1988-05-27', 'praktyka', 42, 9);
INSERT INTO egzaminy VALUES (91, '1993-02-19', 'praktyka', 60, 1);
INSERT INTO egzaminy VALUES (92, '1990-08-30', 'praktyka', 38, 13);
INSERT INTO egzaminy VALUES (93, '1982-09-02', 'praktyka', 59, 10);
INSERT INTO egzaminy VALUES (94, '1986-11-21', 'teoria', 6, 10);
INSERT INTO egzaminy VALUES (95, '2002-08-22', 'praktyka', 56, 3);
INSERT INTO egzaminy VALUES (96, '1981-02-26', 'praktyka', 5, 4);
INSERT INTO egzaminy VALUES (97, '1976-04-09', 'praktyka', 30, 16);
INSERT INTO egzaminy VALUES (98, '1985-02-28', 'teoria', 62, 6);
INSERT INTO egzaminy VALUES (99, '2002-09-11', 'teoria', 2, 2);
INSERT INTO egzaminy VALUES (100, '2001-10-23', 'teoria', 20, 12);
INSERT INTO egzaminy VALUES (101, '2005-02-26', 'teoria', 35, 10);
INSERT INTO egzaminy VALUES (102, '1999-04-07', 'praktyka', 50, 2);
INSERT INTO egzaminy VALUES (103, '2009-04-13', 'teoria', 30, 4);
INSERT INTO egzaminy VALUES (104, '2010-01-14', 'teoria', 18, 14);
INSERT INTO egzaminy VALUES (105, '1975-12-27', 'teoria', 47, 6);
INSERT INTO egzaminy VALUES (106, '2007-09-19', 'teoria', 3, 1);
INSERT INTO egzaminy VALUES (107, '1997-03-30', 'praktyka', 14, 13);
INSERT INTO egzaminy VALUES (108, '2011-08-21', 'praktyka', 29, 14);
INSERT INTO egzaminy VALUES (109, '1989-12-08', 'teoria', 63, 15);
INSERT INTO egzaminy VALUES (110, '1989-08-16', 'praktyka', 5, 8);
INSERT INTO egzaminy VALUES (111, '1980-05-03', 'praktyka', 43, 15);
INSERT INTO egzaminy VALUES (112, '1987-05-21', 'praktyka', 44, 14);
INSERT INTO egzaminy VALUES (113, '2011-12-17', 'praktyka', 10, 2);
INSERT INTO egzaminy VALUES (114, '1984-04-11', 'praktyka', 50, 8);
INSERT INTO egzaminy VALUES (115, '1995-04-27', 'teoria', 17, 3);
INSERT INTO egzaminy VALUES (116, '1980-02-15', 'teoria', 42, 9);
INSERT INTO egzaminy VALUES (117, '1998-07-30', 'teoria', 15, 5);
INSERT INTO egzaminy VALUES (118, '1980-11-20', 'teoria', 56, 5);
INSERT INTO egzaminy VALUES (119, '1993-09-07', 'teoria', 56, 6);
INSERT INTO egzaminy VALUES (120, '2009-08-19', 'praktyka', 26, 5);
INSERT INTO egzaminy VALUES (121, '2009-03-17', 'praktyka', 64, 4);
INSERT INTO egzaminy VALUES (122, '1992-07-30', 'praktyka', 14, 16);
INSERT INTO egzaminy VALUES (123, '1989-11-01', 'teoria', 61, 2);
INSERT INTO egzaminy VALUES (124, '2004-03-30', 'teoria', 10, 9);
INSERT INTO egzaminy VALUES (125, '1997-12-09', 'teoria', 44, 14);
INSERT INTO egzaminy VALUES (126, '1982-06-08', 'teoria', 47, 11);
INSERT INTO egzaminy VALUES (127, '1980-12-25', 'praktyka', 26, 6);
INSERT INTO egzaminy VALUES (128, '1981-08-21', 'praktyka', 33, 13);
INSERT INTO egzaminy VALUES (129, '1984-02-27', 'praktyka', 16, 5);
INSERT INTO egzaminy VALUES (130, '1994-06-20', 'teoria', 33, 12);
INSERT INTO egzaminy VALUES (131, '1987-05-17', 'teoria', 42, 7);
INSERT INTO egzaminy VALUES (132, '1976-07-30', 'teoria', 38, 7);
INSERT INTO egzaminy VALUES (133, '1997-08-24', 'praktyka', 44, 6);
INSERT INTO egzaminy VALUES (134, '2009-05-16', 'teoria', 63, 11);
INSERT INTO egzaminy VALUES (135, '1976-06-16', 'praktyka', 41, 9);
INSERT INTO egzaminy VALUES (136, '2002-01-23', 'praktyka', 28, 10);
INSERT INTO egzaminy VALUES (137, '1977-01-13', 'praktyka', 6, 14);
INSERT INTO egzaminy VALUES (138, '1997-05-21', 'praktyka', 3, 4);
INSERT INTO egzaminy VALUES (139, '2008-10-26', 'praktyka', 51, 14);
INSERT INTO egzaminy VALUES (140, '1997-08-06', 'praktyka', 4, 16);
INSERT INTO egzaminy VALUES (141, '2005-08-07', 'praktyka', 20, 16);
INSERT INTO egzaminy VALUES (142, '1998-06-19', 'teoria', 54, 2);
INSERT INTO egzaminy VALUES (143, '1987-09-14', 'praktyka', 9, 9);
INSERT INTO egzaminy VALUES (144, '2006-10-02', 'praktyka', 7, 8);
INSERT INTO egzaminy VALUES (145, '1979-01-23', 'teoria', 59, 6);
INSERT INTO egzaminy VALUES (146, '2009-09-15', 'praktyka', 23, 16);
INSERT INTO egzaminy VALUES (147, '1989-11-10', 'praktyka', 62, 11);
INSERT INTO egzaminy VALUES (148, '1994-11-11', 'teoria', 47, 15);
INSERT INTO egzaminy VALUES (149, '2000-07-27', 'praktyka', 45, 15);
INSERT INTO egzaminy VALUES (150, '1988-01-09', 'teoria', 60, 6);
INSERT INTO egzaminy VALUES (151, '1979-11-08', 'teoria', 37, 13);
INSERT INTO egzaminy VALUES (152, '1991-03-05', 'teoria', 29, 16);
INSERT INTO egzaminy VALUES (153, '1999-01-14', 'praktyka', 10, 1);
INSERT INTO egzaminy VALUES (154, '2012-03-19', 'teoria', 1, 11);
INSERT INTO egzaminy VALUES (155, '1978-10-18', 'teoria', 61, 15);
INSERT INTO egzaminy VALUES (156, '1977-05-21', 'praktyka', 34, 2);
INSERT INTO egzaminy VALUES (157, '2011-03-20', 'praktyka', 24, 9);
INSERT INTO egzaminy VALUES (158, '1988-04-05', 'teoria', 31, 2);
INSERT INTO egzaminy VALUES (159, '2014-04-04', 'teoria', 49, 12);
INSERT INTO egzaminy VALUES (160, '1990-08-07', 'praktyka', 17, 5);
INSERT INTO egzaminy VALUES (161, '1992-08-01', 'teoria', 12, 7);
INSERT INTO egzaminy VALUES (162, '2005-12-21', 'praktyka', 6, 16);
INSERT INTO egzaminy VALUES (163, '2001-11-26', 'praktyka', 2, 6);
INSERT INTO egzaminy VALUES (164, '1978-05-23', 'praktyka', 62, 9);
INSERT INTO egzaminy VALUES (165, '1976-02-22', 'teoria', 32, 4);
INSERT INTO egzaminy VALUES (166, '1980-05-05', 'teoria', 15, 10);
INSERT INTO egzaminy VALUES (167, '1998-05-15', 'teoria', 55, 6);
INSERT INTO egzaminy VALUES (168, '1998-01-27', 'praktyka', 19, 10);
INSERT INTO egzaminy VALUES (169, '1978-06-03', 'teoria', 20, 8);
INSERT INTO egzaminy VALUES (170, '1986-05-11', 'praktyka', 62, 13);
INSERT INTO egzaminy VALUES (171, '2000-11-25', 'praktyka', 61, 3);
INSERT INTO egzaminy VALUES (172, '2008-08-04', 'praktyka', 36, 14);
INSERT INTO egzaminy VALUES (173, '2014-11-29', 'teoria', 57, 1);
INSERT INTO egzaminy VALUES (174, '2008-08-09', 'teoria', 39, 10);
INSERT INTO egzaminy VALUES (175, '2009-02-13', 'teoria', 16, 4);
INSERT INTO egzaminy VALUES (176, '2010-01-05', 'teoria', 49, 3);
INSERT INTO egzaminy VALUES (177, '1985-11-20', 'teoria', 5, 1);
INSERT INTO egzaminy VALUES (178, '1981-04-01', 'praktyka', 60, 3);
INSERT INTO egzaminy VALUES (179, '1996-05-28', 'teoria', 24, 4);
INSERT INTO egzaminy VALUES (180, '2003-10-15', 'praktyka', 57, 12);
INSERT INTO egzaminy VALUES (181, '2013-12-27', 'praktyka', 20, 5);
INSERT INTO egzaminy VALUES (182, '1989-02-15', 'teoria', 31, 11);
INSERT INTO egzaminy VALUES (183, '1995-09-11', 'praktyka', 26, 2);
INSERT INTO egzaminy VALUES (184, '1984-11-20', 'praktyka', 42, 13);
INSERT INTO egzaminy VALUES (185, '1977-10-18', 'praktyka', 41, 7);
INSERT INTO egzaminy VALUES (186, '2009-03-12', 'praktyka', 43, 5);
INSERT INTO egzaminy VALUES (187, '1985-05-16', 'teoria', 52, 16);
INSERT INTO egzaminy VALUES (188, '2002-08-17', 'teoria', 39, 6);
INSERT INTO egzaminy VALUES (189, '1993-04-26', 'teoria', 54, 5);
INSERT INTO egzaminy VALUES (190, '2010-12-20', 'teoria', 39, 2);
INSERT INTO egzaminy VALUES (191, '1998-01-04', 'praktyka', 47, 10);
INSERT INTO egzaminy VALUES (192, '2012-09-08', 'praktyka', 26, 6);
INSERT INTO egzaminy VALUES (193, '2005-10-01', 'praktyka', 39, 11);
INSERT INTO egzaminy VALUES (194, '1982-06-26', 'praktyka', 1, 16);
INSERT INTO egzaminy VALUES (195, '2013-01-07', 'teoria', 38, 5);
INSERT INTO egzaminy VALUES (196, '2000-01-01', 'praktyka', 53, 11);
INSERT INTO egzaminy VALUES (197, '2009-02-16', 'teoria', 33, 13);
INSERT INTO egzaminy VALUES (198, '1999-03-14', 'teoria', 57, 9);
INSERT INTO egzaminy VALUES (199, '2014-04-12', 'teoria', 34, 2);
INSERT INTO egzaminy VALUES (200, '1999-08-14', 'praktyka', 23, 11);
INSERT INTO egzaminy VALUES (201, '1994-08-21', 'teoria', 25, 12);
INSERT INTO egzaminy VALUES (202, '2001-11-15', 'teoria', 46, 13);
INSERT INTO egzaminy VALUES (203, '2000-03-23', 'teoria', 4, 3);
INSERT INTO egzaminy VALUES (204, '1994-03-04', 'praktyka', 28, 11);
INSERT INTO egzaminy VALUES (205, '1980-04-10', 'teoria', 43, 1);
INSERT INTO egzaminy VALUES (206, '1996-10-30', 'praktyka', 13, 8);
INSERT INTO egzaminy VALUES (207, '1998-11-22', 'teoria', 20, 16);
INSERT INTO egzaminy VALUES (208, '1999-06-16', 'praktyka', 57, 9);
INSERT INTO egzaminy VALUES (209, '2004-04-27', 'praktyka', 16, 15);
INSERT INTO egzaminy VALUES (210, '1992-09-02', 'praktyka', 64, 4);
INSERT INTO egzaminy VALUES (211, '2001-02-19', 'praktyka', 34, 14);
INSERT INTO egzaminy VALUES (212, '1984-01-14', 'teoria', 12, 8);
INSERT INTO egzaminy VALUES (213, '1993-12-01', 'teoria', 7, 13);
INSERT INTO egzaminy VALUES (214, '1982-04-06', 'teoria', 58, 7);
INSERT INTO egzaminy VALUES (215, '1982-11-19', 'teoria', 6, 11);
INSERT INTO egzaminy VALUES (216, '2003-12-08', 'teoria', 26, 1);
INSERT INTO egzaminy VALUES (217, '1977-04-25', 'teoria', 31, 4);
INSERT INTO egzaminy VALUES (218, '2011-05-10', 'praktyka', 8, 6);
INSERT INTO egzaminy VALUES (219, '1995-03-27', 'teoria', 40, 2);
INSERT INTO egzaminy VALUES (220, '2000-12-29', 'praktyka', 33, 2);
INSERT INTO egzaminy VALUES (221, '2013-05-27', 'teoria', 10, 11);
INSERT INTO egzaminy VALUES (222, '1980-08-12', 'teoria', 50, 4);
INSERT INTO egzaminy VALUES (223, '1975-02-24', 'teoria', 63, 11);
INSERT INTO egzaminy VALUES (224, '1995-03-23', 'praktyka', 15, 8);
INSERT INTO egzaminy VALUES (225, '2013-12-09', 'praktyka', 44, 15);
INSERT INTO egzaminy VALUES (226, '2002-10-18', 'teoria', 23, 5);
INSERT INTO egzaminy VALUES (227, '1988-12-25', 'praktyka', 9, 10);
INSERT INTO egzaminy VALUES (228, '1980-10-03', 'praktyka', 41, 13);
INSERT INTO egzaminy VALUES (229, '1977-06-28', 'praktyka', 42, 14);
INSERT INTO egzaminy VALUES (230, '2009-04-25', 'praktyka', 18, 9);
INSERT INTO egzaminy VALUES (231, '2014-09-16', 'praktyka', 9, 1);
INSERT INTO egzaminy VALUES (232, '1989-06-06', 'praktyka', 9, 5);
INSERT INTO egzaminy VALUES (233, '1990-02-08', 'praktyka', 39, 6);
INSERT INTO egzaminy VALUES (234, '1993-05-29', 'teoria', 12, 13);
INSERT INTO egzaminy VALUES (235, '2005-06-20', 'teoria', 14, 6);
INSERT INTO egzaminy VALUES (236, '2002-01-26', 'praktyka', 39, 10);
INSERT INTO egzaminy VALUES (237, '1987-06-06', 'praktyka', 28, 16);
INSERT INTO egzaminy VALUES (238, '2011-04-05', 'teoria', 58, 11);
INSERT INTO egzaminy VALUES (239, '2013-04-20', 'teoria', 14, 7);
INSERT INTO egzaminy VALUES (240, '1988-12-10', 'praktyka', 55, 1);
INSERT INTO egzaminy VALUES (241, '2012-06-02', 'teoria', 23, 4);
INSERT INTO egzaminy VALUES (242, '1983-11-03', 'teoria', 43, 5);
INSERT INTO egzaminy VALUES (243, '1997-07-26', 'teoria', 32, 9);
INSERT INTO egzaminy VALUES (244, '2012-11-24', 'praktyka', 64, 9);
INSERT INTO egzaminy VALUES (245, '1989-01-03', 'teoria', 13, 3);
INSERT INTO egzaminy VALUES (246, '1985-03-23', 'teoria', 10, 11);
INSERT INTO egzaminy VALUES (247, '2001-06-13', 'teoria', 34, 16);
INSERT INTO egzaminy VALUES (248, '2006-12-22', 'praktyka', 51, 14);
INSERT INTO egzaminy VALUES (249, '2005-01-02', 'teoria', 57, 3);
INSERT INTO egzaminy VALUES (250, '1977-12-03', 'praktyka', 41, 3);
INSERT INTO egzaminy VALUES (251, '1991-03-29', 'praktyka', 10, 6);
INSERT INTO egzaminy VALUES (252, '1981-01-14', 'teoria', 40, 9);
INSERT INTO egzaminy VALUES (253, '1993-11-30', 'teoria', 37, 11);
INSERT INTO egzaminy VALUES (254, '1987-07-25', 'teoria', 12, 3);
INSERT INTO egzaminy VALUES (255, '2000-10-20', 'teoria', 44, 3);
INSERT INTO egzaminy VALUES (256, '1985-05-03', 'praktyka', 17, 7);
INSERT INTO egzaminy VALUES (257, '1987-12-05', 'teoria', 3, 10);
INSERT INTO egzaminy VALUES (258, '2002-09-20', 'praktyka', 52, 4);
INSERT INTO egzaminy VALUES (259, '1979-05-24', 'praktyka', 32, 9);
INSERT INTO egzaminy VALUES (260, '1984-06-21', 'praktyka', 41, 10);
INSERT INTO egzaminy VALUES (261, '1979-03-26', 'teoria', 42, 15);
INSERT INTO egzaminy VALUES (262, '1998-02-10', 'teoria', 57, 8);
INSERT INTO egzaminy VALUES (263, '2001-08-20', 'teoria', 54, 7);
INSERT INTO egzaminy VALUES (264, '2011-11-27', 'teoria', 57, 15);
INSERT INTO egzaminy VALUES (265, '1976-02-26', 'teoria', 5, 16);
INSERT INTO egzaminy VALUES (266, '1992-01-17', 'praktyka', 10, 4);
INSERT INTO egzaminy VALUES (267, '1979-05-25', 'teoria', 58, 9);
INSERT INTO egzaminy VALUES (268, '1999-04-08', 'teoria', 45, 9);
INSERT INTO egzaminy VALUES (269, '2001-01-29', 'praktyka', 2, 12);
INSERT INTO egzaminy VALUES (270, '2005-04-17', 'teoria', 19, 9);
INSERT INTO egzaminy VALUES (271, '2012-08-18', 'teoria', 51, 3);
INSERT INTO egzaminy VALUES (272, '1985-03-24', 'praktyka', 49, 5);
INSERT INTO egzaminy VALUES (273, '1993-01-03', 'teoria', 37, 5);
INSERT INTO egzaminy VALUES (274, '2012-11-26', 'praktyka', 39, 15);
INSERT INTO egzaminy VALUES (275, '2002-10-20', 'teoria', 27, 5);
INSERT INTO egzaminy VALUES (276, '1975-04-02', 'teoria', 63, 2);
INSERT INTO egzaminy VALUES (277, '2010-09-19', 'praktyka', 35, 9);
INSERT INTO egzaminy VALUES (278, '1994-05-05', 'teoria', 10, 13);
INSERT INTO egzaminy VALUES (279, '1998-08-15', 'praktyka', 24, 2);
INSERT INTO egzaminy VALUES (280, '1986-11-07', 'praktyka', 2, 9);
INSERT INTO egzaminy VALUES (281, '2007-10-19', 'praktyka', 59, 15);
INSERT INTO egzaminy VALUES (282, '1976-07-28', 'teoria', 13, 10);
INSERT INTO egzaminy VALUES (283, '2000-08-09', 'praktyka', 11, 8);
INSERT INTO egzaminy VALUES (284, '1997-11-11', 'teoria', 23, 6);
INSERT INTO egzaminy VALUES (285, '1993-06-16', 'praktyka', 31, 10);
INSERT INTO egzaminy VALUES (286, '1999-03-23', 'praktyka', 63, 14);
INSERT INTO egzaminy VALUES (287, '2014-05-26', 'praktyka', 26, 8);
INSERT INTO egzaminy VALUES (288, '1982-08-04', 'teoria', 54, 2);
INSERT INTO egzaminy VALUES (289, '1988-12-02', 'teoria', 61, 3);
INSERT INTO egzaminy VALUES (290, '1992-11-24', 'praktyka', 63, 2);
INSERT INTO egzaminy VALUES (291, '1992-08-07', 'praktyka', 16, 15);
INSERT INTO egzaminy VALUES (292, '1976-07-15', 'praktyka', 5, 9);
INSERT INTO egzaminy VALUES (293, '2002-05-18', 'praktyka', 34, 9);
INSERT INTO egzaminy VALUES (294, '1979-07-26', 'teoria', 27, 1);
INSERT INTO egzaminy VALUES (295, '1976-12-05', 'teoria', 4, 14);
INSERT INTO egzaminy VALUES (296, '1989-02-13', 'praktyka', 26, 4);
INSERT INTO egzaminy VALUES (297, '1996-07-09', 'teoria', 7, 15);
INSERT INTO egzaminy VALUES (298, '2002-02-09', 'praktyka', 5, 13);
INSERT INTO egzaminy VALUES (299, '2005-05-07', 'praktyka', 24, 5);
INSERT INTO egzaminy VALUES (300, '1977-10-04', 'praktyka', 31, 4);
INSERT INTO wyniki_egzaminów VALUES (178, 73, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (116, 98, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (272, 80, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (294, 52, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (270, 71, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (11, 43, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (120, 61, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (89, 78, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (150, 66, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (263, 1, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (80, 9, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (160, 78, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (48, 62, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (56, 91, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (203, 80, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (57, 39, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (5, 9, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (262, 91, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (99, 75, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (52, 83, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (44, 63, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (54, 82, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (161, 15, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (206, 12, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (21, 52, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (43, 36, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (63, 40, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (22, 93, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (255, 30, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (111, 94, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (61, 66, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (178, 17, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (168, 58, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (46, 56, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (295, 57, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (17, 49, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (103, 71, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (234, 47, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (259, 95, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (224, 11, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (278, 12, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (257, 63, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (9, 2, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (102, 81, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (4, 15, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (14, 47, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (94, 86, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (248, 49, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (60, 48, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (110, 14, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (67, 71, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (203, 9, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (75, 93, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (91, 90, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (275, 55, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (103, 94, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (93, 72, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (137, 61, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (83, 71, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (31, 96, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (40, 40, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (129, 52, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (258, 22, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (67, 33, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (104, 8, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (68, 38, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (8, 67, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (114, 33, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (224, 88, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (40, 5, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (79, 93, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (77, 39, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (247, 69, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (106, 16, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (234, 58, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (242, 99, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (186, 39, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (296, 32, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (224, 38, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (177, 78, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (298, 53, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (20, 7, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (164, 76, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (126, 51, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (42, 42, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (126, 17, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (54, 31, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (282, 60, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (258, 88, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (59, 50, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (114, 60, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (285, 65, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (106, 85, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (210, 54, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (60, 38, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (197, 97, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (36, 40, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (241, 2, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (61, 71, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (36, 66, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (150, 81, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (287, 93, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (130, 34, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (30, 86, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (77, 2, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (203, 19, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (142, 98, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (264, 55, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (165, 88, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (274, 52, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (33, 33, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (15, 50, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (226, 96, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (50, 64, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (105, 63, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (278, 79, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (195, 66, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (91, 15, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (47, 53, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (210, 67, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (198, 51, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (294, 48, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (213, 9, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (193, 3, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (49, 33, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (75, 75, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (73, 94, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (13, 89, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (139, 87, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (87, 8, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (168, 71, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (25, 5, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (289, 70, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (196, 35, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (180, 66, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (154, 90, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (277, 56, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (215, 73, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (195, 51, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (255, 55, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (76, 36, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (70, 9, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (237, 94, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (201, 53, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (178, 87, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (37, 46, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (152, 33, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (169, 45, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (205, 44, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (191, 32, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (177, 85, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (38, 67, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (205, 90, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (135, 80, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (165, 75, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (119, 67, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (11, 65, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (196, 15, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (151, 72, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (238, 90, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (31, 44, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (49, 17, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (83, 1, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (265, 100, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (266, 29, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (100, 34, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (75, 62, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (257, 21, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (196, 25, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (41, 48, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (100, 59, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (259, 21, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (150, 61, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (46, 96, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (57, 24, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (65, 44, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (291, 75, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (67, 20, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (294, 19, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (283, 69, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (93, 87, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (188, 19, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (143, 39, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (203, 95, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (238, 98, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (65, 40, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (59, 86, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (7, 65, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (99, 3, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (142, 97, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (139, 55, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (158, 68, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (205, 82, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (198, 19, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (177, 92, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (198, 2, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (204, 99, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (247, 50, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (204, 88, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (7, 80, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (113, 50, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (168, 48, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (96, 91, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (89, 7, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (62, 90, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (236, 70, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (226, 65, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (171, 100, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (164, 10, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (129, 73, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (163, 99, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (172, 63, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (285, 2, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (218, 50, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (1, 59, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (68, 97, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (21, 35, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (233, 65, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (247, 80, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (142, 30, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (83, 58, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (260, 38, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (296, 62, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (210, 65, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (99, 86, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (50, 2, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (33, 25, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (226, 6, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (104, 41, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (92, 13, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (225, 75, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (190, 58, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (139, 63, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (246, 39, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (86, 40, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (166, 98, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (90, 4, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (269, 41, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (167, 63, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (72, 56, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (219, 96, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (216, 34, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (171, 12, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (277, 72, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (61, 79, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (247, 98, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (164, 74, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (245, 38, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (208, 25, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (110, 94, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (205, 79, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (250, 79, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (157, 38, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (288, 14, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (187, 75, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (112, 3, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (279, 58, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (140, 51, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (7, 28, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (177, 54, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (162, 60, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (69, 47, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (150, 96, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (178, 50, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (265, 20, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (164, 94, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (264, 34, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (124, 16, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (206, 57, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (25, 56, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (57, 6, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (35, 78, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (49, 61, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (206, 53, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (38, 64, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (31, 55, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (63, 68, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (176, 1, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (258, 4, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (281, 69, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (230, 72, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (76, 18, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (133, 67, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (121, 89, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (209, 93, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (293, 51, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (254, 29, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (298, 89, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (13, 9, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (78, 73, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (39, 83, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (272, 27, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (219, 69, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (219, 29, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (210, 58, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (46, 77, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (37, 53, 'zdał');
INSERT INTO prawa_jazdy VALUES ('25910/04/4824', 42, '1986-04-27', false);
INSERT INTO prawa_jazdy VALUES ('87561/10/7633', 4, '2007-10-04', false);
INSERT INTO prawa_jazdy VALUES ('16933/04/0764', 9, '1983-04-22', false);
INSERT INTO prawa_jazdy VALUES ('37715/07/4981', 91, '1994-07-14', false);
INSERT INTO prawa_jazdy VALUES ('63382/01/2373', 42, '1991-01-12', false);
INSERT INTO prawa_jazdy VALUES ('04931/10/6682', 54, '2014-10-24', false);
INSERT INTO prawa_jazdy VALUES ('13387/06/8611', 89, '2010-06-13', false);
INSERT INTO prawa_jazdy VALUES ('59985/03/8374', 99, '2011-03-15', true);
INSERT INTO prawa_jazdy VALUES ('18054/12/3332', 8, '2011-12-17', false);
INSERT INTO prawa_jazdy VALUES ('34886/07/8816', 35, '2010-07-15', false);
INSERT INTO prawa_jazdy VALUES ('19850/05/8041', 51, '1978-05-21', false);
INSERT INTO prawa_jazdy VALUES ('28753/09/8616', 10, '1980-09-14', false);
INSERT INTO prawa_jazdy VALUES ('78590/11/3421', 3, '1979-11-26', false);
INSERT INTO prawa_jazdy VALUES ('07225/02/9009', 89, '2009-02-08', false);
INSERT INTO prawa_jazdy VALUES ('07397/05/8893', 2, '2010-05-07', false);
INSERT INTO prawa_jazdy VALUES ('03800/05/0582', 62, '1989-05-12', false);
INSERT INTO prawa_jazdy VALUES ('93012/04/5023', 41, '1996-04-15', false);
INSERT INTO prawa_jazdy VALUES ('28821/12/9549', 84, '1991-12-08', false);
INSERT INTO prawa_jazdy VALUES ('52667/06/8703', 23, '1988-06-13', false);
INSERT INTO prawa_jazdy VALUES ('66606/01/5574', 95, '1983-01-18', false);
INSERT INTO prawa_jazdy VALUES ('91065/09/8229', 42, '2000-09-26', false);
INSERT INTO prawa_jazdy VALUES ('39815/01/4211', 15, '1989-01-19', false);
INSERT INTO prawa_jazdy VALUES ('33146/04/1012', 31, '1982-04-15', false);
INSERT INTO prawa_jazdy VALUES ('53002/08/0497', 86, '1976-08-01', false);
INSERT INTO prawa_jazdy VALUES ('66911/04/0592', 43, '1983-04-04', false);
INSERT INTO prawa_jazdy VALUES ('76741/08/0560', 83, '2001-08-08', false);
INSERT INTO prawa_jazdy VALUES ('84362/12/2752', 76, '1992-12-09', false);
INSERT INTO prawa_jazdy VALUES ('22590/12/5615', 75, '2001-12-07', false);
INSERT INTO prawa_jazdy VALUES ('51337/07/6110', 48, '1980-07-04', false);
INSERT INTO prawa_jazdy VALUES ('95839/03/3598', 97, '1987-03-11', false);
INSERT INTO prawa_jazdy VALUES ('18561/09/0108', 73, '1998-09-01', false);
INSERT INTO prawa_jazdy VALUES ('06913/07/7740', 2, '1983-07-18', false);
INSERT INTO prawa_jazdy VALUES ('49959/08/6126', 16, '1994-08-18', false);
INSERT INTO prawa_jazdy VALUES ('40478/09/3030', 23, '2001-09-26', false);
INSERT INTO prawa_jazdy VALUES ('14265/12/3162', 8, '1985-12-23', false);
INSERT INTO prawa_jazdy VALUES ('78910/12/3896', 71, '2013-12-13', false);
INSERT INTO prawa_jazdy VALUES ('90626/07/8824', 93, '1981-07-13', false);
INSERT INTO prawa_jazdy VALUES ('68538/02/5590', 1, '1981-02-12', false);
INSERT INTO prawa_jazdy VALUES ('55465/01/1911', 81, '2012-01-03', false);
INSERT INTO prawa_jazdy VALUES ('30909/12/6393', 96, '2000-12-19', false);
INSERT INTO prawa_jazdy VALUES ('34381/11/9762', 1, '1979-11-01', false);
INSERT INTO prawa_jazdy VALUES ('19371/10/4721', 61, '1979-10-06', false);
INSERT INTO prawa_jazdy VALUES ('03339/06/8419', 33, '1989-06-13', false);
INSERT INTO prawa_jazdy VALUES ('87172/02/8197', 70, '2007-02-13', false);
INSERT INTO prawa_jazdy VALUES ('70725/08/0156', 81, '1977-08-07', false);
INSERT INTO prawa_jazdy VALUES ('85672/01/8678', 15, '1992-01-07', false);
INSERT INTO prawa_jazdy VALUES ('88670/06/3156', 67, '1981-06-09', false);
INSERT INTO prawa_jazdy VALUES ('23308/12/2730', 81, '1977-12-08', false);
INSERT INTO prawa_jazdy VALUES ('66665/06/2378', 71, '2013-06-29', false);
INSERT INTO prawa_jazdy VALUES ('00423/06/0532', 86, '2001-06-18', false);
INSERT INTO prawa_jazdy VALUES ('24890/07/6571', 79, '1997-07-11', false);
INSERT INTO prawa_jazdy VALUES ('78998/10/4434', 26, '1996-10-03', false);
INSERT INTO prawa_jazdy VALUES ('84020/02/0127', 90, '2011-02-08', false);
INSERT INTO prawa_jazdy VALUES ('17906/07/8144', 21, '1995-07-28', false);
INSERT INTO prawa_jazdy VALUES ('40646/03/6789', 99, '1983-03-20', false);
INSERT INTO prawa_jazdy VALUES ('89919/10/0351', 91, '1981-10-13', false);
INSERT INTO prawa_jazdy VALUES ('66008/03/9747', 42, '1990-03-02', false);
INSERT INTO prawa_jazdy VALUES ('46727/01/9561', 33, '1981-01-16', false);
INSERT INTO prawa_jazdy VALUES ('05861/08/1802', 34, '2007-08-18', false);
INSERT INTO prawa_jazdy VALUES ('60608/08/3552', 67, '2004-08-12', false);
INSERT INTO prawa_jazdy VALUES ('84409/06/5628', 33, '1979-06-18', false);
INSERT INTO prawa_jazdy VALUES ('90270/05/8081', 13, '1985-05-22', false);
INSERT INTO prawa_jazdy VALUES ('28502/08/1336', 86, '1991-08-08', false);
INSERT INTO prawa_jazdy VALUES ('65165/03/3373', 57, '1989-03-21', false);
INSERT INTO prawa_jazdy VALUES ('38078/11/7930', 38, '2000-11-03', false);
INSERT INTO prawa_jazdy VALUES ('32509/05/6862', 17, '1984-05-15', false);
INSERT INTO prawa_jazdy VALUES ('29559/04/7284', 44, '2010-04-21', false);
INSERT INTO prawa_jazdy VALUES ('50415/03/9347', 82, '2011-03-30', false);
INSERT INTO prawa_jazdy VALUES ('53975/05/4541', 32, '1984-05-17', false);
INSERT INTO prawa_jazdy VALUES ('30590/06/9258', 83, '2002-06-06', false);
INSERT INTO prawa_jazdy VALUES ('72128/09/0134', 83, '2000-09-04', false);
INSERT INTO prawa_jazdy VALUES ('49789/07/2921', 98, '2012-07-13', false);
INSERT INTO prawa_jazdy VALUES ('94468/03/6068', 38, '1976-03-30', false);
INSERT INTO prawa_jazdy VALUES ('26177/09/8791', 40, '1990-09-18', false);
INSERT INTO prawa_jazdy VALUES ('67273/06/8514', 44, '1999-06-21', false);
INSERT INTO prawa_jazdy VALUES ('08826/05/9168', 19, '1990-05-20', false);
INSERT INTO prawa_jazdy VALUES ('57036/07/4293', 46, '1976-07-09', false);
INSERT INTO prawa_jazdy VALUES ('43261/05/1982', 44, '2004-05-04', false);
INSERT INTO prawa_jazdy VALUES ('39197/02/3458', 77, '1975-02-22', false);
INSERT INTO prawa_jazdy VALUES ('09374/11/7350', 38, '2006-11-01', false);
INSERT INTO prawa_jazdy VALUES ('58497/10/5061', 66, '2008-10-22', false);
INSERT INTO prawa_jazdy VALUES ('08129/12/6935', 43, '2014-12-10', false);
INSERT INTO prawa_jazdy VALUES ('16984/08/4741', 31, '1991-08-07', false);
INSERT INTO prawa_jazdy VALUES ('39539/01/8884', 1, '2007-01-15', false);
INSERT INTO prawa_jazdy VALUES ('84210/03/3959', 84, '1995-03-05', false);
INSERT INTO prawa_jazdy VALUES ('74816/09/3652', 50, '1978-09-02', true);
INSERT INTO prawa_jazdy VALUES ('08502/01/9133', 57, '2013-01-20', false);
INSERT INTO prawa_jazdy VALUES ('52439/05/2458', 41, '1997-05-12', false);
INSERT INTO prawa_jazdy VALUES ('01031/06/5345', 23, '2005-06-29', false);
INSERT INTO prawa_jazdy VALUES ('22284/09/6139', 100, '1993-09-02', false);
INSERT INTO prawa_jazdy VALUES ('96119/08/1419', 11, '1992-08-24', true);
INSERT INTO prawa_jazdy VALUES ('47769/10/1657', 18, '1999-10-07', false);
INSERT INTO prawa_jazdy VALUES ('76464/11/8041', 92, '2013-11-22', false);
INSERT INTO prawa_jazdy VALUES ('63200/01/1912', 26, '1975-01-05', false);
INSERT INTO prawa_jazdy VALUES ('01179/10/8648', 70, '1976-10-01', false);
INSERT INTO prawa_jazdy VALUES ('07980/05/3934', 49, '2004-05-16', false);
INSERT INTO prawa_jazdy VALUES ('70574/12/9739', 77, '2001-12-26', false);
INSERT INTO prawa_jazdy VALUES ('61488/06/5718', 10, '1992-06-28', false);
INSERT INTO prawa_jazdy VALUES ('03886/03/5724', 67, '2007-03-13', false);
INSERT INTO prawa_jazdy VALUES ('28490/02/1908', 96, '2010-02-26', false);
INSERT INTO prawa_jazdy VALUES ('14428/07/4269', 44, '2012-07-10', false);
INSERT INTO prawa_jazdy VALUES ('33262/05/7740', 19, '1981-05-06', false);
INSERT INTO prawa_jazdy VALUES ('71996/12/5369', 75, '1983-12-21', false);
INSERT INTO prawa_jazdy VALUES ('90726/09/0009', 73, '1996-09-03', false);
INSERT INTO prawa_jazdy VALUES ('91072/09/2807', 75, '2004-09-01', false);
INSERT INTO prawa_jazdy VALUES ('22035/11/0710', 27, '1984-11-29', false);
INSERT INTO prawa_jazdy VALUES ('03916/12/0012', 4, '1996-12-08', true);
INSERT INTO prawa_jazdy VALUES ('29864/10/1911', 2, '1986-10-09', false);
INSERT INTO prawa_jazdy VALUES ('46642/02/5787', 95, '1996-02-28', false);
INSERT INTO prawa_jazdy VALUES ('32173/07/9490', 62, '1976-07-24', false);
INSERT INTO prawa_jazdy VALUES ('63300/01/1647', 51, '1978-01-07', false);
INSERT INTO prawa_jazdy VALUES ('64916/05/2823', 85, '2009-05-07', false);
INSERT INTO prawa_jazdy VALUES ('94060/03/6627', 72, '2001-03-15', false);
INSERT INTO prawa_jazdy VALUES ('15679/02/5089', 77, '1989-02-01', false);
INSERT INTO prawa_jazdy VALUES ('95781/04/8614', 1, '2008-04-22', false);
INSERT INTO prawa_jazdy VALUES ('81216/03/8876', 14, '1998-03-30', false);
INSERT INTO prawa_jazdy VALUES ('05990/07/6026', 26, '2010-07-16', false);
INSERT INTO prawa_jazdy VALUES ('63046/10/2743', 66, '1997-10-30', false);
INSERT INTO prawa_jazdy VALUES ('87793/10/6854', 43, '1986-10-10', false);
INSERT INTO prawa_jazdy VALUES ('30616/06/6741', 10, '1986-06-16', false);
INSERT INTO prawa_jazdy VALUES ('78456/02/1619', 40, '1991-02-04', false);
INSERT INTO prawa_jazdy VALUES ('74327/02/9457', 87, '1999-02-09', false);
INSERT INTO prawa_jazdy VALUES ('67756/07/2345', 52, '1975-07-13', false);
INSERT INTO prawa_jazdy VALUES ('16182/01/6217', 16, '2000-01-14', false);
INSERT INTO prawa_jazdy VALUES ('76263/05/0112', 17, '1980-05-01', false);
INSERT INTO prawa_jazdy VALUES ('44850/09/9538', 76, '2002-09-13', false);
INSERT INTO prawa_jazdy VALUES ('24302/07/5667', 5, '1990-07-04', false);
INSERT INTO prawa_jazdy VALUES ('12158/09/9311', 10, '2006-09-18', false);
INSERT INTO prawa_jazdy VALUES ('45579/09/8926', 75, '1994-09-01', false);
INSERT INTO prawa_jazdy VALUES ('70884/07/0559', 81, '1980-07-02', false);
INSERT INTO prawa_jazdy VALUES ('17262/08/8548', 87, '1977-08-01', false);
INSERT INTO prawa_jazdy VALUES ('25998/06/0940', 27, '1981-06-09', false);
INSERT INTO prawa_jazdy VALUES ('44771/10/0340', 60, '1996-10-26', false);
INSERT INTO prawa_jazdy VALUES ('75613/09/7037', 31, '2003-09-19', false);
INSERT INTO prawa_jazdy VALUES ('30474/06/4486', 68, '2014-06-30', true);
INSERT INTO prawa_jazdy VALUES ('67234/05/0477', 5, '1991-05-05', false);
INSERT INTO prawa_jazdy VALUES ('67117/04/7841', 23, '1992-04-03', false);
INSERT INTO prawa_jazdy VALUES ('59426/10/6738', 65, '1992-10-09', false);
INSERT INTO prawa_jazdy VALUES ('42739/11/0467', 13, '1992-11-26', false);
INSERT INTO prawa_jazdy VALUES ('89640/01/2890', 33, '2006-01-19', false);
INSERT INTO prawa_jazdy VALUES ('62104/10/8530', 63, '2013-10-25', false);
INSERT INTO prawa_jazdy VALUES ('97498/06/3585', 72, '1983-06-27', false);
INSERT INTO prawa_jazdy VALUES ('68622/12/7568', 58, '2001-12-20', false);
INSERT INTO prawa_jazdy VALUES ('67974/07/3748', 72, '2013-07-14', false);
INSERT INTO prawa_jazdy VALUES ('27287/01/8305', 84, '1979-01-11', false);
INSERT INTO prawa_jazdy VALUES ('41300/03/4079', 19, '1990-03-21', false);
INSERT INTO prawa_jazdy VALUES ('49768/06/9467', 32, '1983-06-25', false);
INSERT INTO prawa_jazdy VALUES ('08661/06/1615', 69, '2009-06-07', false);
INSERT INTO prawa_jazdy VALUES ('51690/02/3714', 11, '1992-02-23', false);
INSERT INTO prawa_jazdy VALUES ('00500/12/2615', 90, '1978-12-28', false);
INSERT INTO prawa_jazdy_kategorie VALUES ('81216/03/8876', 'X');
INSERT INTO prawa_jazdy_kategorie VALUES ('03800/05/0582', 'J');
INSERT INTO prawa_jazdy_kategorie VALUES ('78456/02/1619', 'W');
INSERT INTO prawa_jazdy_kategorie VALUES ('66606/01/5574', 'T');
INSERT INTO prawa_jazdy_kategorie VALUES ('65165/03/3373', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('24302/07/5667', 'I');
INSERT INTO prawa_jazdy_kategorie VALUES ('19371/10/4721', 'R');
INSERT INTO prawa_jazdy_kategorie VALUES ('63046/10/2743', 'E');
INSERT INTO prawa_jazdy_kategorie VALUES ('57036/07/4293', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('30909/12/6393', 'Z');
INSERT INTO prawa_jazdy_kategorie VALUES ('03339/06/8419', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('74327/02/9457', 'G');
INSERT INTO prawa_jazdy_kategorie VALUES ('84210/03/3959', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('93012/04/5023', 'Y');
INSERT INTO prawa_jazdy_kategorie VALUES ('49768/06/9467', 'H');
INSERT INTO prawa_jazdy_kategorie VALUES ('22035/11/0710', 'T');
INSERT INTO prawa_jazdy_kategorie VALUES ('18054/12/3332', 'J');
INSERT INTO prawa_jazdy_kategorie VALUES ('89919/10/0351', 'W');
INSERT INTO prawa_jazdy_kategorie VALUES ('84020/02/0127', 'Z');
INSERT INTO prawa_jazdy_kategorie VALUES ('66008/03/9747', 'U');
INSERT INTO prawa_jazdy_kategorie VALUES ('50415/03/9347', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('87172/02/8197', 'K');
INSERT INTO prawa_jazdy_kategorie VALUES ('22590/12/5615', 'P');
INSERT INTO prawa_jazdy_kategorie VALUES ('70725/08/0156', 'L');
INSERT INTO prawa_jazdy_kategorie VALUES ('47769/10/1657', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('91065/09/8229', 'Z');
INSERT INTO prawa_jazdy_kategorie VALUES ('30590/06/9258', 'E');
INSERT INTO prawa_jazdy_kategorie VALUES ('52439/05/2458', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('37715/07/4981', 'F');
INSERT INTO prawa_jazdy_kategorie VALUES ('84362/12/2752', 'H');
INSERT INTO prawa_jazdy_kategorie VALUES ('67117/04/7841', 'V');
INSERT INTO prawa_jazdy_kategorie VALUES ('95781/04/8614', 'F');
INSERT INTO prawa_jazdy_kategorie VALUES ('46642/02/5787', 'S');
INSERT INTO prawa_jazdy_kategorie VALUES ('12158/09/9311', 'K');
INSERT INTO prawa_jazdy_kategorie VALUES ('63200/01/1912', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('96119/08/1419', 'Y');
INSERT INTO prawa_jazdy_kategorie VALUES ('84210/03/3959', 'T');
INSERT INTO prawa_jazdy_kategorie VALUES ('51690/02/3714', 'M');
INSERT INTO prawa_jazdy_kategorie VALUES ('63382/01/2373', 'Y');
INSERT INTO prawa_jazdy_kategorie VALUES ('08129/12/6935', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('37715/07/4981', 'R');
INSERT INTO prawa_jazdy_kategorie VALUES ('49959/08/6126', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('41300/03/4079', 'O');
INSERT INTO prawa_jazdy_kategorie VALUES ('45579/09/8926', 'F');
INSERT INTO prawa_jazdy_kategorie VALUES ('44850/09/9538', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('63382/01/2373', 'I');
INSERT INTO prawa_jazdy_kategorie VALUES ('22284/09/6139', 'R');
INSERT INTO prawa_jazdy_kategorie VALUES ('15679/02/5089', 'H');
INSERT INTO prawa_jazdy_kategorie VALUES ('63200/01/1912', 'U');
INSERT INTO prawa_jazdy_kategorie VALUES ('28753/09/8616', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('43261/05/1982', 'Z');
INSERT INTO prawa_jazdy_kategorie VALUES ('25910/04/4824', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('67117/04/7841', 'M');
INSERT INTO prawa_jazdy_kategorie VALUES ('43261/05/1982', 'H');
INSERT INTO prawa_jazdy_kategorie VALUES ('34381/11/9762', 'Q');
INSERT INTO prawa_jazdy_kategorie VALUES ('76464/11/8041', 'N');
INSERT INTO prawa_jazdy_kategorie VALUES ('38078/11/7930', 'R');
INSERT INTO prawa_jazdy_kategorie VALUES ('28821/12/9549', 'F');
INSERT INTO prawa_jazdy_kategorie VALUES ('08661/06/1615', 'U');
INSERT INTO prawa_jazdy_kategorie VALUES ('78590/11/3421', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('13387/06/8611', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('96119/08/1419', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('68622/12/7568', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('61488/06/5718', 'H');
INSERT INTO prawa_jazdy_kategorie VALUES ('61488/06/5718', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('08826/05/9168', 'U');
INSERT INTO prawa_jazdy_kategorie VALUES ('94060/03/6627', 'L');
INSERT INTO prawa_jazdy_kategorie VALUES ('03339/06/8419', 'Z');
INSERT INTO prawa_jazdy_kategorie VALUES ('26177/09/8791', 'R');
INSERT INTO prawa_jazdy_kategorie VALUES ('70725/08/0156', 'J');
INSERT INTO prawa_jazdy_kategorie VALUES ('18561/09/0108', 'U');
INSERT INTO prawa_jazdy_kategorie VALUES ('63300/01/1647', 'S');
INSERT INTO prawa_jazdy_kategorie VALUES ('07225/02/9009', 'N');
INSERT INTO prawa_jazdy_kategorie VALUES ('89919/10/0351', 'S');
INSERT INTO prawa_jazdy_kategorie VALUES ('70884/07/0559', 'O');
INSERT INTO prawa_jazdy_kategorie VALUES ('89640/01/2890', 'K');
INSERT INTO prawa_jazdy_kategorie VALUES ('30909/12/6393', 'H');
INSERT INTO prawa_jazdy_kategorie VALUES ('01031/06/5345', 'P');
INSERT INTO prawa_jazdy_kategorie VALUES ('52439/05/2458', 'V');
INSERT INTO prawa_jazdy_kategorie VALUES ('72128/09/0134', 'G');
INSERT INTO prawa_jazdy_kategorie VALUES ('03886/03/5724', 'F');
INSERT INTO prawa_jazdy_kategorie VALUES ('07225/02/9009', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('67756/07/2345', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('95781/04/8614', 'R');
INSERT INTO prawa_jazdy_kategorie VALUES ('57036/07/4293', 'K');
INSERT INTO prawa_jazdy_kategorie VALUES ('07397/05/8893', 'E');
INSERT INTO prawa_jazdy_kategorie VALUES ('03886/03/5724', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('71996/12/5369', 'S');
INSERT INTO prawa_jazdy_kategorie VALUES ('29864/10/1911', 'Y');
INSERT INTO prawa_jazdy_kategorie VALUES ('57036/07/4293', 'Z');
INSERT INTO prawa_jazdy_kategorie VALUES ('18561/09/0108', 'H');
INSERT INTO prawa_jazdy_kategorie VALUES ('22590/12/5615', 'F');
INSERT INTO prawa_jazdy_kategorie VALUES ('28490/02/1908', 'X');
INSERT INTO prawa_jazdy_kategorie VALUES ('40646/03/6789', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('91072/09/2807', 'Q');
INSERT INTO prawa_jazdy_kategorie VALUES ('66911/04/0592', 'T');
INSERT INTO prawa_jazdy_kategorie VALUES ('39815/01/4211', 'J');
INSERT INTO prawa_jazdy_kategorie VALUES ('93012/04/5023', 'R');
INSERT INTO prawa_jazdy_kategorie VALUES ('88670/06/3156', 'Y');
INSERT INTO prawa_jazdy_kategorie VALUES ('68622/12/7568', 'H');
INSERT INTO prawa_jazdy_kategorie VALUES ('76464/11/8041', 'K');
INSERT INTO prawa_jazdy_kategorie VALUES ('25998/06/0940', 'O');
INSERT INTO prawa_jazdy_kategorie VALUES ('49959/08/6126', 'K');
INSERT INTO prawa_jazdy_kategorie VALUES ('03916/12/0012', 'Z');
INSERT INTO prawa_jazdy_kategorie VALUES ('88670/06/3156', 'V');
INSERT INTO prawa_jazdy_kategorie VALUES ('45579/09/8926', 'W');
INSERT INTO prawa_jazdy_kategorie VALUES ('84020/02/0127', 'N');
INSERT INTO prawa_jazdy_kategorie VALUES ('28490/02/1908', 'R');
INSERT INTO prawa_jazdy_kategorie VALUES ('33146/04/1012', 'X');
INSERT INTO prawa_jazdy_kategorie VALUES ('22284/09/6139', 'H');
INSERT INTO prawa_jazdy_kategorie VALUES ('08129/12/6935', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('16984/08/4741', 'M');
INSERT INTO prawa_jazdy_kategorie VALUES ('22035/11/0710', 'Y');
INSERT INTO prawa_jazdy_kategorie VALUES ('00423/06/0532', 'Y');
INSERT INTO prawa_jazdy_kategorie VALUES ('49959/08/6126', 'N');
INSERT INTO prawa_jazdy_kategorie VALUES ('09374/11/7350', 'I');
INSERT INTO prawa_jazdy_kategorie VALUES ('23308/12/2730', 'U');
INSERT INTO prawa_jazdy_kategorie VALUES ('29559/04/7284', 'J');
INSERT INTO prawa_jazdy_kategorie VALUES ('03886/03/5724', 'H');
INSERT INTO prawa_jazdy_kategorie VALUES ('78456/02/1619', 'O');
INSERT INTO prawa_jazdy_kategorie VALUES ('46642/02/5787', 'L');
INSERT INTO prawa_jazdy_kategorie VALUES ('66911/04/0592', 'E');
INSERT INTO prawa_jazdy_kategorie VALUES ('05861/08/1802', 'N');
INSERT INTO prawa_jazdy_kategorie VALUES ('38078/11/7930', 'L');
INSERT INTO prawa_jazdy_kategorie VALUES ('58497/10/5061', 'R');
INSERT INTO prawa_jazdy_kategorie VALUES ('78590/11/3421', 'Z');
INSERT INTO prawa_jazdy_kategorie VALUES ('16182/01/6217', 'S');
INSERT INTO prawa_jazdy_kategorie VALUES ('03800/05/0582', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('49768/06/9467', 'S');
INSERT INTO prawa_jazdy_kategorie VALUES ('75613/09/7037', 'Q');
INSERT INTO prawa_jazdy_kategorie VALUES ('22035/11/0710', 'I');
INSERT INTO prawa_jazdy_kategorie VALUES ('16933/04/0764', 'E');
INSERT INTO prawa_jazdy_kategorie VALUES ('66911/04/0592', 'Y');
INSERT INTO prawa_jazdy_kategorie VALUES ('78910/12/3896', 'J');
INSERT INTO prawa_jazdy_kategorie VALUES ('67974/07/3748', 'Y');
INSERT INTO prawa_jazdy_kategorie VALUES ('49789/07/2921', 'J');
INSERT INTO prawa_jazdy_kategorie VALUES ('60608/08/3552', 'K');
INSERT INTO prawa_jazdy_kategorie VALUES ('29559/04/7284', 'H');
INSERT INTO prawa_jazdy_kategorie VALUES ('53002/08/0497', 'O');
INSERT INTO prawa_jazdy_kategorie VALUES ('14428/07/4269', 'I');
INSERT INTO prawa_jazdy_kategorie VALUES ('52439/05/2458', 'M');
INSERT INTO prawa_jazdy_kategorie VALUES ('28821/12/9549', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('19850/05/8041', 'X');
INSERT INTO prawa_jazdy_kategorie VALUES ('03339/06/8419', 'Y');
INSERT INTO prawa_jazdy_kategorie VALUES ('00500/12/2615', 'J');
INSERT INTO prawa_jazdy_kategorie VALUES ('14265/12/3162', 'Z');
INSERT INTO prawa_jazdy_kategorie VALUES ('89640/01/2890', 'O');
INSERT INTO prawa_jazdy_kategorie VALUES ('90270/05/8081', 'V');
INSERT INTO prawa_jazdy_kategorie VALUES ('60608/08/3552', 'T');
INSERT INTO prawa_jazdy_kategorie VALUES ('68622/12/7568', 'S');
INSERT INTO prawa_jazdy_kategorie VALUES ('46727/01/9561', 'G');
INSERT INTO prawa_jazdy_kategorie VALUES ('66008/03/9747', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('95781/04/8614', 'S');
INSERT INTO prawa_jazdy_kategorie VALUES ('67234/05/0477', 'P');
INSERT INTO prawa_jazdy_kategorie VALUES ('63382/01/2373', 'E');
INSERT INTO prawa_jazdy_kategorie VALUES ('85672/01/8678', 'R');
INSERT INTO prawa_jazdy_kategorie VALUES ('16933/04/0764', 'J');
INSERT INTO prawa_jazdy_kategorie VALUES ('03916/12/0012', 'X');
INSERT INTO prawa_jazdy_kategorie VALUES ('51690/02/3714', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('49789/07/2921', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('08826/05/9168', 'M');
INSERT INTO prawa_jazdy_kategorie VALUES ('70725/08/0156', 'G');
INSERT INTO prawa_jazdy_kategorie VALUES ('84210/03/3959', 'P');
INSERT INTO prawa_jazdy_kategorie VALUES ('66606/01/5574', 'I');
INSERT INTO prawa_jazdy_kategorie VALUES ('05861/08/1802', 'S');
INSERT INTO prawa_jazdy_kategorie VALUES ('01179/10/8648', 'M');
INSERT INTO prawa_jazdy_kategorie VALUES ('49768/06/9467', 'G');
INSERT INTO prawa_jazdy_kategorie VALUES ('34381/11/9762', 'F');
INSERT INTO prawa_jazdy_kategorie VALUES ('25910/04/4824', 'Q');
INSERT INTO prawa_jazdy_kategorie VALUES ('39815/01/4211', 'X');
INSERT INTO prawa_jazdy_kategorie VALUES ('97498/06/3585', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('19850/05/8041', 'E');
INSERT INTO prawa_jazdy_kategorie VALUES ('97498/06/3585', 'Q');
INSERT INTO prawa_jazdy_kategorie VALUES ('51690/02/3714', 'Y');
INSERT INTO prawa_jazdy_kategorie VALUES ('72128/09/0134', 'U');
INSERT INTO prawa_jazdy_kategorie VALUES ('76464/11/8041', 'P');
INSERT INTO prawa_jazdy_kategorie VALUES ('01031/06/5345', 'W');
INSERT INTO prawa_jazdy_kategorie VALUES ('33146/04/1012', 'Z');
INSERT INTO prawa_jazdy_kategorie VALUES ('46727/01/9561', 'O');
INSERT INTO prawa_jazdy_kategorie VALUES ('74816/09/3652', 'V');
INSERT INTO prawa_jazdy_kategorie VALUES ('51690/02/3714', 'N');
INSERT INTO prawa_jazdy_kategorie VALUES ('07397/05/8893', 'I');
INSERT INTO prawa_jazdy_kategorie VALUES ('28821/12/9549', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('90626/07/8824', 'E');
INSERT INTO prawa_jazdy_kategorie VALUES ('07225/02/9009', 'K');
INSERT INTO prawa_jazdy_kategorie VALUES ('93012/04/5023', 'E');
INSERT INTO prawa_jazdy_kategorie VALUES ('51337/07/6110', 'J');
INSERT INTO prawa_jazdy_kategorie VALUES ('67117/04/7841', 'U');
INSERT INTO prawa_jazdy_kategorie VALUES ('67756/07/2345', 'Q');
INSERT INTO prawa_jazdy_kategorie VALUES ('16933/04/0764', 'W');
INSERT INTO prawa_jazdy_kategorie VALUES ('50415/03/9347', 'J');
INSERT INTO prawa_jazdy_kategorie VALUES ('64916/05/2823', 'N');
INSERT INTO prawa_jazdy_kategorie VALUES ('12158/09/9311', 'Q');
INSERT INTO prawa_jazdy_kategorie VALUES ('50415/03/9347', 'M');
INSERT INTO prawa_jazdy_kategorie VALUES ('05990/07/6026', 'G');
INSERT INTO prawa_jazdy_kategorie VALUES ('62104/10/8530', 'H');
INSERT INTO prawa_jazdy_kategorie VALUES ('29864/10/1911', 'P');
INSERT INTO prawa_jazdy_kategorie VALUES ('72128/09/0134', 'Q');
INSERT INTO prawa_jazdy_kategorie VALUES ('41300/03/4079', 'J');
INSERT INTO prawa_jazdy_kategorie VALUES ('51337/07/6110', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('34886/07/8816', 'Q');
INSERT INTO prawa_jazdy_kategorie VALUES ('49789/07/2921', 'O');
INSERT INTO prawa_jazdy_kategorie VALUES ('30474/06/4486', 'T');
INSERT INTO prawa_jazdy_kategorie VALUES ('88670/06/3156', 'Z');
INSERT INTO prawa_jazdy_kategorie VALUES ('34381/11/9762', 'R');
INSERT INTO prawa_jazdy_kategorie VALUES ('90626/07/8824', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('44850/09/9538', 'R');
INSERT INTO prawa_jazdy_kategorie VALUES ('68538/02/5590', 'W');
INSERT INTO prawa_jazdy_kategorie VALUES ('14428/07/4269', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('70725/08/0156', 'Q');
INSERT INTO prawa_jazdy_kategorie VALUES ('26177/09/8791', 'Y');
INSERT INTO prawa_jazdy_kategorie VALUES ('49768/06/9467', 'Y');
INSERT INTO prawa_jazdy_kategorie VALUES ('59426/10/6738', 'Q');
INSERT INTO prawa_jazdy_kategorie VALUES ('18561/09/0108', 'J');
INSERT INTO prawa_jazdy_kategorie VALUES ('78998/10/4434', 'S');
INSERT INTO prawa_jazdy_kategorie VALUES ('23308/12/2730', 'R');
INSERT INTO prawa_jazdy_kategorie VALUES ('93012/04/5023', 'U');
INSERT INTO prawa_jazdy_kategorie VALUES ('28753/09/8616', 'X');
INSERT INTO prawa_jazdy_kategorie VALUES ('52667/06/8703', 'N');
INSERT INTO prawa_jazdy_kategorie VALUES ('34381/11/9762', 'I');
INSERT INTO prawa_jazdy_kategorie VALUES ('44850/09/9538', 'I');
INSERT INTO prawa_jazdy_kategorie VALUES ('07225/02/9009', 'M');
INSERT INTO prawa_jazdy_kategorie VALUES ('97498/06/3585', 'F');
INSERT INTO prawa_jazdy_kategorie VALUES ('34886/07/8816', 'M');
INSERT INTO prawa_jazdy_kategorie VALUES ('39539/01/8884', 'Q');
INSERT INTO prawa_jazdy_kategorie VALUES ('26177/09/8791', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('87793/10/6854', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('23308/12/2730', 'H');
INSERT INTO prawa_jazdy_kategorie VALUES ('08661/06/1615', 'X');
INSERT INTO prawa_jazdy_kategorie VALUES ('32173/07/9490', 'W');
INSERT INTO prawa_jazdy_kategorie VALUES ('28502/08/1336', 'M');
INSERT INTO prawa_jazdy_kategorie VALUES ('66606/01/5574', 'Z');
INSERT INTO prawa_jazdy_kategorie VALUES ('95839/03/3598', 'L');
INSERT INTO prawa_jazdy_kategorie VALUES ('84210/03/3959', 'L');
INSERT INTO prawa_jazdy_kategorie VALUES ('00423/06/0532', 'T');
INSERT INTO prawa_jazdy_kategorie VALUES ('28490/02/1908', 'E');
INSERT INTO prawa_jazdy_kategorie VALUES ('15679/02/5089', 'W');
INSERT INTO prawa_jazdy_kategorie VALUES ('03800/05/0582', 'R');
INSERT INTO prawa_jazdy_kategorie VALUES ('84210/03/3959', 'U');
INSERT INTO prawa_jazdy_kategorie VALUES ('51690/02/3714', 'H');
INSERT INTO prawa_jazdy_kategorie VALUES ('84409/06/5628', 'T');
INSERT INTO prawa_jazdy_kategorie VALUES ('78998/10/4434', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('74816/09/3652', 'K');
INSERT INTO prawa_jazdy_kategorie VALUES ('58497/10/5061', 'L');
INSERT INTO prawa_jazdy_kategorie VALUES ('28490/02/1908', 'L');
INSERT INTO prawa_jazdy_kategorie VALUES ('75613/09/7037', 'Z');
INSERT INTO prawa_jazdy_kategorie VALUES ('50415/03/9347', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('55465/01/1911', 'M');
INSERT INTO prawa_jazdy_kategorie VALUES ('47769/10/1657', 'N');
INSERT INTO prawa_jazdy_kategorie VALUES ('30616/06/6741', 'I');
INSERT INTO prawa_jazdy_kategorie VALUES ('67117/04/7841', 'S');
INSERT INTO prawa_jazdy_kategorie VALUES ('22035/11/0710', 'O');
INSERT INTO prawa_jazdy_kategorie VALUES ('90270/05/8081', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('29864/10/1911', 'Z');
INSERT INTO prawa_jazdy_kategorie VALUES ('05990/07/6026', 'H');
INSERT INTO prawa_jazdy_kategorie VALUES ('39197/02/3458', 'V');
INSERT INTO prawa_jazdy_kategorie VALUES ('96119/08/1419', 'G');
INSERT INTO prawa_jazdy_kategorie VALUES ('72128/09/0134', 'S');
INSERT INTO prawa_jazdy_kategorie VALUES ('78998/10/4434', 'P');
INSERT INTO prawa_jazdy_kategorie VALUES ('94060/03/6627', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('68538/02/5590', 'F');
INSERT INTO prawa_jazdy_kategorie VALUES ('22284/09/6139', 'P');
INSERT INTO prawa_jazdy_kategorie VALUES ('58497/10/5061', 'S');
INSERT INTO prawa_jazdy_kategorie VALUES ('16933/04/0764', 'R');
INSERT INTO prawa_jazdy_kategorie VALUES ('26177/09/8791', 'L');
INSERT INTO prawa_jazdy_kategorie VALUES ('87793/10/6854', 'Q');
INSERT INTO prawa_jazdy_kategorie VALUES ('22284/09/6139', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('63382/01/2373', 'G');
INSERT INTO prawa_jazdy_kategorie VALUES ('57036/07/4293', 'P');
INSERT INTO prawa_jazdy_kategorie VALUES ('03916/12/0012', 'I');
INSERT INTO prawa_jazdy_kategorie VALUES ('50415/03/9347', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('07397/05/8893', 'F');
INSERT INTO prawa_jazdy_kategorie VALUES ('14428/07/4269', 'M');
INSERT INTO prawa_jazdy_kategorie VALUES ('51337/07/6110', 'Z');
INSERT INTO prawa_jazdy_kategorie VALUES ('46727/01/9561', 'E');
INSERT INTO prawa_jazdy_kategorie VALUES ('01031/06/5345', 'U');
INSERT INTO prawa_jazdy_kategorie VALUES ('49789/07/2921', 'F');
INSERT INTO prawa_jazdy_kategorie VALUES ('76263/05/0112', 'F');
INSERT INTO prawa_jazdy_kategorie VALUES ('32173/07/9490', 'Q');
INSERT INTO prawa_jazdy_kategorie VALUES ('90726/09/0009', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('81216/03/8876', 'J');
INSERT INTO prawa_jazdy_kategorie VALUES ('29559/04/7284', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('16933/04/0764', 'N');
INSERT INTO prawa_jazdy_kategorie VALUES ('89919/10/0351', 'O');
INSERT INTO prawa_jazdy_kategorie VALUES ('45579/09/8926', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('24302/07/5667', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('61488/06/5718', 'E');
INSERT INTO prawa_jazdy_kategorie VALUES ('17906/07/8144', 'O');
INSERT INTO prawa_jazdy_kategorie VALUES ('51337/07/6110', 'H');
INSERT INTO prawa_jazdy_kategorie VALUES ('37715/07/4981', 'U');
INSERT INTO prawa_jazdy_kategorie VALUES ('76741/08/0560', 'P');
INSERT INTO prawa_jazdy_kategorie VALUES ('30474/06/4486', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('94468/03/6068', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('25910/04/4824', 'Y');
INSERT INTO pojazdy VALUES (1, 'ESI294S', '1980-08-23', 'fiat', 'panda', 'osobowy');
INSERT INTO pojazdy VALUES (2, 'DBA75S1', '1994-01-28', 'nissan', '240-sx', 'osobowy');
INSERT INTO pojazdy VALUES (3, 'RDE073U', '2011-07-13', 'rolls-royce', 'silver-down', 'osobowy');
INSERT INTO pojazdy VALUES (4, 'ZS1R62Z', '1977-06-17', 'chevrolet', 'monte-carlo', 'osobowy');
INSERT INTO pojazdy VALUES (5, 'NO1W5B1', '1988-02-09', 'aston-martin', 'db4', 'osobowy');
INSERT INTO pojazdy VALUES (6, 'RLU4DCN', '1995-09-23', 'ferrari', '365', 'osobowy');
INSERT INTO pojazdy VALUES (7, 'ZCH035J', '1979-09-01', 'aro', 'muscel', 'osobowy');
INSERT INTO pojazdy VALUES (8, 'DZA452V', '1978-08-18', 'honda', 'aerodeck', 'osobowy');
INSERT INTO pojazdy VALUES (9, 'SGL99V7', '1988-01-14', 'dodge', 'journey', 'osobowy');
INSERT INTO pojazdy VALUES (10, 'NLI71RH', '2011-11-05', 'mercedes-benz', '230', 'osobowy');
INSERT INTO pojazdy VALUES (11, 'ESI964I', '1984-02-23', 'syrena', '101', 'osobowy');
INSERT INTO pojazdy VALUES (12, 'SBI1QBH', '2008-09-14', 'fiat', 'seicento', 'osobowy');
INSERT INTO pojazdy VALUES (13, 'SMI4G3Q', '2013-05-24', 'mitsubishi', 'space-wagon', 'osobowy');
INSERT INTO pojazdy VALUES (14, 'EPI25AO', '1994-07-17', 'fiat', 'doblo', 'ciężarowy');
INSERT INTO pojazdy VALUES (15, 'DZL1486', '1999-01-02', 'peugeot', '404', 'osobowy');
INSERT INTO pojazdy VALUES (16, 'RTA28O9', '2000-12-10', 'maserati', '430', 'osobowy');
INSERT INTO pojazdy VALUES (17, 'FMI2E6I', '2000-04-06', 'cadillac', 'xlr', 'osobowy');
INSERT INTO pojazdy VALUES (18, 'ELW400W', '2008-10-10', 'pontiac', 'trans-am', 'osobowy');
INSERT INTO pojazdy VALUES (19, 'CWA16P4', '1985-05-05', 'volvo', 'xc-60', 'osobowy');
INSERT INTO pojazdy VALUES (20, 'DZA93WP', '1996-01-03', 'volvo', '960', 'osobowy');
INSERT INTO pojazdy VALUES (21, 'SZO3H74', '2005-04-13', 'chevrolet', 'nova', 'osobowy');
INSERT INTO pojazdy VALUES (22, 'DBL45OE', '1988-02-20', 'fiat', 'bravo', 'osobowy');
INSERT INTO pojazdy VALUES (23, 'PKE2DU2', '2014-04-17', 'infiniti', 'i30', 'osobowy');
INSERT INTO pojazdy VALUES (24, 'GMB99UE', '1988-06-01', 'mitsubishi', 'canter', 'osobowy');
INSERT INTO pojazdy VALUES (25, 'PSL9V97', '2002-02-11', 'opel', 'mokka', 'osobowy');
INSERT INTO pojazdy VALUES (26, 'DBA4Y3U', '1991-02-01', 'chevrolet', 'trax', 'osobowy');
INSERT INTO pojazdy VALUES (27, 'ST1P64P', '2010-02-19', 'cadillac', 'brougham', 'osobowy');
INSERT INTO pojazdy VALUES (28, 'DWR2N50', '1998-10-07', 'ford', 'tourneo-courier', 'osobowy');
INSERT INTO pojazdy VALUES (29, 'EOP8LA2', '2003-06-18', 'chevrolet', 'corsica', 'osobowy');
INSERT INTO pojazdy VALUES (30, 'KMY9637', '2011-10-10', 'volkswagen', 'cc', 'osobowy');
INSERT INTO pojazdy VALUES (31, 'SLU6O52', '2011-07-03', 'dacia', '1400', 'osobowy');
INSERT INTO pojazdy VALUES (32, 'NNI9XA6', '2007-09-01', 'ferrari', '750', 'osobowy');
INSERT INTO pojazdy VALUES (33, 'EOP8894', '1977-05-22', 'nissan', 'urvan', 'osobowy');
INSERT INTO pojazdy VALUES (34, 'WPI6DIU', '1975-09-30', 'nissan', 'almera', 'osobowy');
INSERT INTO pojazdy VALUES (35, 'PL0C90X', '2010-05-17', 'uaz', '469-b', 'osobowy');
INSERT INTO pojazdy VALUES (36, 'EPI83J4', '1985-02-10', 'pontiac', 'le-mans', 'osobowy');
INSERT INTO pojazdy VALUES (37, 'PNT11O5', '1986-06-25', 'mazda', 'mpv', 'osobowy');
INSERT INTO pojazdy VALUES (38, 'EPA1064', '1978-11-27', 'rover', 'mg', 'osobowy');
INSERT INTO pojazdy VALUES (39, 'RLU74X2', '2006-08-06', 'volvo', '245', 'osobowy');
INSERT INTO pojazdy VALUES (40, 'RBI3T99', '1975-08-27', 'aixam', 'a721', 'osobowy');
INSERT INTO pojazdy VALUES (41, 'RNI3712', '2004-07-26', 'vauxhall', 'vectra', 'osobowy');
INSERT INTO pojazdy VALUES (42, 'DWL189F', '1980-03-22', 'ford', 'ka', 'osobowy');
INSERT INTO pojazdy VALUES (43, 'WBR62ZO', '1991-01-25', 'isuzu', 'gemini', 'osobowy');
INSERT INTO pojazdy VALUES (44, 'KPR90YR', '2003-03-22', 'chevrolet', 'monte-carlo', 'osobowy');
INSERT INTO pojazdy VALUES (45, 'TBU20N7', '1977-08-29', 'peugeot', '308-cc', 'osobowy');
INSERT INTO pojazdy VALUES (46, 'TLW3WTV', '2004-03-30', 'citroen', 'cx', 'osobowy');
INSERT INTO pojazdy VALUES (47, 'EPA9KH7', '2012-03-06', 'dodge', 'dart', 'osobowy');
INSERT INTO pojazdy VALUES (48, 'NKE2X19', '2012-04-05', 'renault', 'latitude', 'osobowy');
INSERT INTO pojazdy VALUES (49, 'CG76625', '1976-08-27', 'volvo', '945', 'osobowy');
INSERT INTO pojazdy VALUES (50, 'DLB57D9', '2005-05-06', 'nissan', 'tiida', 'osobowy');
INSERT INTO pojazdy VALUES (51, 'FSD9T9Z', '1983-07-11', 'porsche', '924', 'osobowy');
INSERT INTO pojazdy VALUES (52, 'SH713MO', '1983-04-23', 'austin', 'allegro', 'osobowy');
INSERT INTO pojazdy VALUES (53, 'DZG67Z4', '1999-12-19', 'volkswagen', 'passat-cc', 'osobowy');
INSERT INTO pojazdy VALUES (54, 'ZSD916O', '2011-09-26', 'opel', 'pick-up-sportcap', 'osobowy');
INSERT INTO pojazdy VALUES (55, 'ESK6190', '1997-05-24', 'rover', 'mini', 'ciężarowy');
INSERT INTO pojazdy VALUES (56, 'NSZ3G6Z', '1981-06-28', 'mitsubishi', 'i-miev', 'osobowy');
INSERT INTO pojazdy VALUES (57, 'CWL5GMI', '1993-06-30', 'opel', 'omega', 'osobowy');
INSERT INTO pojazdy VALUES (58, 'KMI3U7N', '1990-12-16', 'jeep', 'grand-cherokee', 'osobowy');
INSERT INTO pojazdy VALUES (59, 'NO75445', '1997-03-23', 'seat', 'malaga', 'osobowy');
INSERT INTO pojazdy VALUES (60, 'PPL9E80', '2001-12-22', 'porsche', 'panamera', 'osobowy');
INSERT INTO pojazdy VALUES (61, 'TOP5O9Z', '1983-07-07', 'toyota', 'auris', 'osobowy');
INSERT INTO pojazdy VALUES (62, 'DOL9981', '2008-02-18', 'daewoo', 'rezzo', 'osobowy');
INSERT INTO pojazdy VALUES (63, 'NNM72AI', '1985-11-03', 'mitsubishi', '3000gt', 'osobowy');
INSERT INTO pojazdy VALUES (64, 'LJA4BY9', '1995-07-14', 'ferrari', '250', 'osobowy');
INSERT INTO pojazdy VALUES (65, 'OKR1502', '1990-08-28', 'lotus', 'elan', 'osobowy');
INSERT INTO pojazdy VALUES (66, 'RT639A4', '1997-10-20', 'lancia', 'beta', 'osobowy');
INSERT INTO pojazdy VALUES (67, 'LU2571M', '1994-04-04', 'jaguar', 'xf', 'osobowy');
INSERT INTO pojazdy VALUES (68, 'GDA60H9', '1991-11-24', 'ford', 'freestyle', 'osobowy');
INSERT INTO pojazdy VALUES (69, 'DDZ9KOT', '1989-05-16', 'ford', 'streetka', 'osobowy');
INSERT INTO pojazdy VALUES (70, 'WSI6126', '1978-10-29', 'honda', 'shuttle', 'osobowy');
INSERT INTO pojazdy VALUES (71, 'GS1996G', '1977-04-09', 'dacia', 'solenza', 'osobowy');
INSERT INTO pojazdy VALUES (72, 'LCH940K', '1987-05-30', 'nissan', 'pulsar', 'osobowy');
INSERT INTO pojazdy VALUES (73, 'WO3E206', '1987-02-27', 'volkswagen', 'golf-plus', 'osobowy');
INSERT INTO pojazdy VALUES (74, 'FSW6Z5C', '2012-05-21', 'dodge', 'caliber', 'osobowy');
INSERT INTO pojazdy VALUES (75, 'ZS1K080', '2007-04-29', 'rover', 'montego', 'osobowy');
INSERT INTO pojazdy VALUES (76, 'NBR5P68', '2005-06-10', 'aston-martin', 'db2', 'osobowy');
INSERT INTO pojazdy VALUES (77, 'OPO1M61', '1986-06-16', 'renault', 'scenic-rx4', 'osobowy');
INSERT INTO pojazdy VALUES (78, 'WLI433B', '1982-07-12', 'seat', 'terra', 'osobowy');
INSERT INTO pojazdy VALUES (79, 'RSR130J', '1977-10-06', 'renault', '11', 'osobowy');
INSERT INTO pojazdy VALUES (80, 'NGI3K10', '2007-02-26', 'audi', 'a7', 'osobowy');
INSERT INTO pojazdy VALUES (81, 'LKS4984', '2001-05-07', 'volvo', '262', 'osobowy');
INSERT INTO pojazdy VALUES (82, 'SZA2MBY', '1977-09-17', 'hyundai', 'grand-santa-fe', 'osobowy');
INSERT INTO pojazdy VALUES (83, 'WZU8396', '2006-11-26', 'mitsubishi', 'diamante', 'osobowy');
INSERT INTO pojazdy VALUES (84, 'DL5Q619', '1975-01-06', 'lotus', 'evora', 'osobowy');
INSERT INTO pojazdy VALUES (85, 'EKU25KH', '2002-04-05', 'nissan', 'bluebird', 'osobowy');
INSERT INTO pojazdy VALUES (86, 'WOT4JOP', '1996-04-28', 'audi', '100', 'osobowy');
INSERT INTO pojazdy VALUES (87, 'SBI0SVH', '1999-03-12', 'lexus', 'ct', 'osobowy');
INSERT INTO pojazdy VALUES (88, 'EZD23HF', '2005-09-21', 'chevrolet', 'blazer', 'osobowy');
INSERT INTO pojazdy VALUES (89, 'PRA08Y1', '1991-05-06', 'hyundai', 'tucson', 'osobowy');
INSERT INTO pojazdy VALUES (90, 'RTA2IH3', '1998-03-19', 'land-rover', 'discovery', 'osobowy');
INSERT INTO pojazdy VALUES (91, 'DOL378H', '1991-01-17', 'aston-martin', 'db9', 'osobowy');
INSERT INTO pojazdy VALUES (92, 'LKS9IU2', '2012-11-06', 'ford', 'f250', 'osobowy');
INSERT INTO pojazdy VALUES (93, 'ZPL2YUQ', '1997-02-16', 'mercury', 'zephyr', 'osobowy');
INSERT INTO pojazdy VALUES (94, 'KRA1732', '1978-01-03', 'volvo', '855', 'osobowy');
INSERT INTO pojazdy VALUES (95, 'TSZ7Y1U', '2010-10-13', 'aixam', 'roadline', 'osobowy');
INSERT INTO pojazdy VALUES (96, 'ZSW3I4W', '2002-03-15', 'ligier', 'altul', 'osobowy');
INSERT INTO pojazdy VALUES (97, 'LKR33G7', '1988-03-06', 'toyota', 'crown', 'osobowy');
INSERT INTO pojazdy VALUES (98, 'RST4A5J', '1989-10-29', 'jeep', 'grand-cherokee', 'osobowy');
INSERT INTO pojazdy VALUES (99, 'POZ7FYX', '2003-12-17', 'fiat', '131', 'osobowy');
INSERT INTO pojazdy VALUES (100, 'WZU3F1Z', '2004-03-18', 'bmw', 'x5-m', 'osobowy');
INSERT INTO kierowcy_pojazdy VALUES (54, 25);
INSERT INTO kierowcy_pojazdy VALUES (64, 23);
INSERT INTO kierowcy_pojazdy VALUES (47, 37);
INSERT INTO kierowcy_pojazdy VALUES (60, 75);
INSERT INTO kierowcy_pojazdy VALUES (69, 25);
INSERT INTO kierowcy_pojazdy VALUES (43, 39);
INSERT INTO kierowcy_pojazdy VALUES (53, 89);
INSERT INTO kierowcy_pojazdy VALUES (7, 57);
INSERT INTO kierowcy_pojazdy VALUES (20, 33);
INSERT INTO kierowcy_pojazdy VALUES (42, 82);
INSERT INTO kierowcy_pojazdy VALUES (44, 77);
INSERT INTO kierowcy_pojazdy VALUES (75, 52);
INSERT INTO kierowcy_pojazdy VALUES (40, 20);
INSERT INTO kierowcy_pojazdy VALUES (57, 84);
INSERT INTO kierowcy_pojazdy VALUES (85, 93);
INSERT INTO kierowcy_pojazdy VALUES (69, 22);
INSERT INTO kierowcy_pojazdy VALUES (97, 91);
INSERT INTO kierowcy_pojazdy VALUES (79, 32);
INSERT INTO kierowcy_pojazdy VALUES (58, 95);
INSERT INTO kierowcy_pojazdy VALUES (19, 38);
INSERT INTO kierowcy_pojazdy VALUES (76, 78);
INSERT INTO kierowcy_pojazdy VALUES (66, 13);
INSERT INTO kierowcy_pojazdy VALUES (69, 80);
INSERT INTO kierowcy_pojazdy VALUES (12, 24);
INSERT INTO kierowcy_pojazdy VALUES (6, 88);
INSERT INTO kierowcy_pojazdy VALUES (65, 6);
INSERT INTO kierowcy_pojazdy VALUES (57, 49);
INSERT INTO kierowcy_pojazdy VALUES (20, 91);
INSERT INTO kierowcy_pojazdy VALUES (74, 97);
INSERT INTO kierowcy_pojazdy VALUES (41, 28);
INSERT INTO kierowcy_pojazdy VALUES (50, 11);
INSERT INTO kierowcy_pojazdy VALUES (1, 9);
INSERT INTO kierowcy_pojazdy VALUES (93, 46);
INSERT INTO kierowcy_pojazdy VALUES (40, 79);
INSERT INTO kierowcy_pojazdy VALUES (16, 50);
INSERT INTO kierowcy_pojazdy VALUES (28, 58);
INSERT INTO kierowcy_pojazdy VALUES (22, 43);
INSERT INTO kierowcy_pojazdy VALUES (74, 45);
INSERT INTO kierowcy_pojazdy VALUES (69, 90);
INSERT INTO kierowcy_pojazdy VALUES (29, 85);
INSERT INTO kierowcy_pojazdy VALUES (42, 74);
INSERT INTO kierowcy_pojazdy VALUES (22, 93);
INSERT INTO kierowcy_pojazdy VALUES (83, 51);
INSERT INTO kierowcy_pojazdy VALUES (99, 41);
INSERT INTO kierowcy_pojazdy VALUES (69, 9);
INSERT INTO kierowcy_pojazdy VALUES (71, 39);
INSERT INTO kierowcy_pojazdy VALUES (99, 70);
INSERT INTO kierowcy_pojazdy VALUES (15, 23);
INSERT INTO kierowcy_pojazdy VALUES (1, 91);
INSERT INTO kierowcy_pojazdy VALUES (93, 6);
INSERT INTO kierowcy_pojazdy VALUES (15, 68);
INSERT INTO kierowcy_pojazdy VALUES (62, 72);
INSERT INTO kierowcy_pojazdy VALUES (16, 36);
INSERT INTO kierowcy_pojazdy VALUES (77, 35);
INSERT INTO kierowcy_pojazdy VALUES (71, 84);
INSERT INTO kierowcy_pojazdy VALUES (57, 5);
INSERT INTO kierowcy_pojazdy VALUES (50, 13);
INSERT INTO kierowcy_pojazdy VALUES (15, 30);
INSERT INTO kierowcy_pojazdy VALUES (23, 84);
INSERT INTO kierowcy_pojazdy VALUES (44, 13);
INSERT INTO kierowcy_pojazdy VALUES (51, 43);
INSERT INTO kierowcy_pojazdy VALUES (12, 14);
INSERT INTO kierowcy_pojazdy VALUES (36, 1);
INSERT INTO kierowcy_pojazdy VALUES (92, 78);
INSERT INTO kierowcy_pojazdy VALUES (35, 88);
INSERT INTO kierowcy_pojazdy VALUES (7, 36);
INSERT INTO kierowcy_pojazdy VALUES (7, 49);
INSERT INTO kierowcy_pojazdy VALUES (36, 68);
INSERT INTO kierowcy_pojazdy VALUES (54, 22);
INSERT INTO kierowcy_pojazdy VALUES (58, 64);
INSERT INTO kierowcy_pojazdy VALUES (68, 25);
INSERT INTO kierowcy_pojazdy VALUES (89, 66);
INSERT INTO kierowcy_pojazdy VALUES (96, 17);
INSERT INTO kierowcy_pojazdy VALUES (1, 55);
INSERT INTO kierowcy_pojazdy VALUES (67, 70);
INSERT INTO kierowcy_pojazdy VALUES (12, 44);
INSERT INTO kierowcy_pojazdy VALUES (10, 69);
INSERT INTO kierowcy_pojazdy VALUES (69, 75);
INSERT INTO kierowcy_pojazdy VALUES (52, 45);
INSERT INTO kierowcy_pojazdy VALUES (85, 12);
INSERT INTO kierowcy_pojazdy VALUES (47, 38);
INSERT INTO kierowcy_pojazdy VALUES (38, 91);
INSERT INTO kierowcy_pojazdy VALUES (11, 5);
INSERT INTO kierowcy_pojazdy VALUES (79, 73);
INSERT INTO kierowcy_pojazdy VALUES (88, 64);
INSERT INTO kierowcy_pojazdy VALUES (40, 36);
INSERT INTO kierowcy_pojazdy VALUES (24, 80);
INSERT INTO kierowcy_pojazdy VALUES (34, 48);
INSERT INTO kierowcy_pojazdy VALUES (17, 24);
INSERT INTO kierowcy_pojazdy VALUES (19, 52);
INSERT INTO kierowcy_pojazdy VALUES (20, 28);
INSERT INTO kierowcy_pojazdy VALUES (54, 28);
INSERT INTO kierowcy_pojazdy VALUES (25, 41);
INSERT INTO kierowcy_pojazdy VALUES (52, 5);
INSERT INTO kierowcy_pojazdy VALUES (94, 9);
INSERT INTO kierowcy_pojazdy VALUES (99, 51);
INSERT INTO kierowcy_pojazdy VALUES (7, 31);
INSERT INTO kierowcy_pojazdy VALUES (55, 9);
INSERT INTO kierowcy_pojazdy VALUES (25, 85);
