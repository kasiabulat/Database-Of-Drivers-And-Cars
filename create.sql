BEGIN;
DROP TABLE IF EXISTS pojazdy CASCADE ;
DROP TABLE IF EXISTS kierowcy CASCADE;
DROP TABLE IF EXISTS kierowcy_pojazdy CASCADE;
DROP TABLE IF EXISTS prawa_jazdy CASCADE;
DROP TABLE IF EXISTS marka_model CASCADE;
DROP TABLE IF EXISTS prawa_jazdy_kategorie CASCADE;
DROP TYPE IF EXISTS typ_egzaminu CASCADE;
DROP TABLE IF EXISTS wyniki_egzaminów CASCADE;
DROP TYPE IF EXISTS wynik_egzaminu CASCADE;
DROP TABLE IF EXISTS egzaminatorzy CASCADE;
DROP TABLE IF EXISTS egzaminy CASCADE;
DROP TABLE IF EXISTS ośrodki CASCADE;
DROP TABLE IF EXISTS mandaty CASCADE;
DROP TABLE IF EXISTS mandaty_wystawiający CASCADE;
DROP TABLE IF EXISTS wykroczenia CASCADE;
DROP TABLE IF EXISTS wojewodztwa CASCADE;
DROP TABLE IF EXISTS powiaty CASCADE;
DROP TABLE IF EXISTS miejscowosci CASCADE;
DROP TABLE IF EXISTS ulice CASCADE;


CREATE TABLE marka_model(
	id_marka_model SERIAL NOT NULL PRIMARY KEY,
	marka TEXT,
	model TEXT
);

CREATE TABLE pojazdy(
	id_pojazdu SERIAL PRIMARY KEY,
	nr_rejestracyjny CHAR(7) UNIQUE ,
	numer_vin INT,
	data_rejestracji DATE NOT NULL,
	/* Id_właściciela*/
	id_marka_model INT NOT NULL REFERENCES marka_model(id_marka_model),
	typ TEXT,
	waga_samochodu NUMERIC
);

CREATE TABLE wojewodztwa(
	id_wojewodztwa SERIAL NOT NULL PRIMARY KEY,
	nazwa TEXT
);

CREATE TABLE powiaty(
	id_powiatu SERIAL NOT NULL PRIMARY KEY,
	id_wojewodztwa INT NOT NULL REFERENCES wojewodztwa(id_wojewodztwa),
	nazwa TEXT
);

CREATE TABLE miejscowosci(
	id_miejscowosci SERIAL NOT NULL PRIMARY KEY,
	id_powiatu INT NOT NULL REFERENCES powiaty(id_powiatu),
	nazwa TEXT
);

CREATE TABLE ulice(
	id_ulicy SERIAL NOT NULL PRIMARY KEY,
	ulica TEXT NOT NULL
);

CREATE TABLE kierowcy(
	id_kierowcy SERIAL PRIMARY KEY,
	PESEL CHAR(11) NOT NULL UNIQUE,
	imię VARCHAR(50) NOT NULL ,
	nazwisko VARCHAR(50) NOT NULL,
	plec CHAR(1) NOT NULL CHECK(plec = 'K' OR plec = 'M'),
	email TEXT, /*CHECK*/
	nr_telefonu CHAR(9),
	nr_ulicy INT NOT NULL REFERENCES ulice(id_ulicy),
	nr_domu TEXT,
	kod_pocztowy TEXT,
	nr_miejscowosci INT NOT NULL REFERENCES miejscowosci(id_miejscowosci)
);

CREATE TABLE kierowcy_pojazdy(
	id_kierowcy INT NOT NULL REFERENCES kierowcy,
	id_pojazdu INT NOT NULL REFERENCES pojazdy,
	PRIMARY KEY (id_kierowcy,id_pojazdu)
);

CREATE TABLE prawa_jazdy_kategorie(
	id_kategoria SERIAL NOT NULL PRIMARY KEY,
	kategoria TEXT
);

CREATE TABLE prawa_jazdy(
	numer_prawa_jazdy TEXT PRIMARY KEY ,
	id_właściciela INT REFERENCES kierowcy(id_kierowcy),
	data_wydania DATE NOT NULL,
	międzynarodowe BOOL NOT NULL,
	id_kategoria INT REFERENCES prawa_jazdy_kategorie(id_kategoria)
);


CREATE TYPE TYP_EGZAMINU AS ENUM ('teoria','praktyka');


CREATE TABLE egzaminatorzy(
	id_egzaminatora SERIAL PRIMARY KEY ,
	imię VARCHAR(50) NOT NULL ,
	nazwisko VARCHAR(50) NOT NULL,
	numer_licencji TEXT
);

CREATE TABLE ośrodki(
	id_ośrodka SERIAL PRIMARY KEY ,
	nazwa TEXT NOT NULL ,
	nr_ulicy INT NOT NULL REFERENCES ulice(id_ulicy),
	nr_budynku TEXT,
	kod_pocztowy TEXT,
	nr_miejscowosci INT NOT NULL REFERENCES miejscowosci(id_miejscowosci)
);

CREATE TABLE egzaminy(
	id_egzaminu SERIAL PRIMARY KEY,
	data_przeprowadzenia DATE NOT NULL ,
	typ TYP_EGZAMINU NOT NULL ,
	id_egzaminatora INT NOT NULL REFERENCES egzaminatorzy NOT NULL ,
	id_ośrodka INT NOT NULL REFERENCES ośrodki(id_ośrodka),
	id_kategoria INT NOT NULL REFERENCES prawa_jazdy_kategorie(id_kategoria)
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

--sprawdzanie poprawnosci wprowadzonych punktow karnych
CREATE OR REPLACE FUNCTION wykroczenia_check() RETURNS trigger AS $$
BEGIN
	IF(NEW.punkty_karne > 24 OR NEW.punkty_karne < 0)
	THEN
		RAISE EXCEPTION 'niepoprawna liczba punktow karnych';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS wykroczenia_check ON wykroczenia;

CREATE TRIGGER wykroczenia_check BEFORE INSERT OR UPDATE ON wykroczenia
FOR EACH ROW EXECUTE PROCEDURE wykroczenia_check();

--sprawdzanie poprawnosci wprowadzonego prawa jazdy
CREATE OR REPLACE FUNCTION prawa_jazdy_check() RETURNS trigger AS $$
BEGIN
	IF EXISTS(SELECT numer_prawa_jazdy
	FROM prawa_jazdy
	WHERE id_właściciela = NEW.id_właściciela
	AND międzynarodowe != NEW.międzynarodowe)
	THEN 
		RAISE EXCEPTION 'Ten kierowca juz ma prawo jazdy';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS prawa_jazdy_check ON prawa_jazdy;

CREATE TRIGGER prawa_jazdy_check BEFORE INSERT OR UPDATE ON prawa_jazdy
FOR EACH ROW EXECUTE PROCEDURE prawa_jazdy_check();

--sprawdzanie czy jak dodajemy do tabeli prawa_jazdy_kategorie jakies prawo jazdy to czy jest ono w tabeli prawa jazdy
CREATE OR REPLACE FUNCTION pj_kategorie() RETURNS trigger AS $$
BEGIN
	IF NOT EXISTS(SELECT *
	FROM prawa_jazdy 
	WHERE numer_prawa_jazdy = NEW.numer_prawa_jazdy)
	THEN 
		RAISE EXCEPTION 'Brak tego prawa jazdy w tabeli prawa jazdy';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS pj_kategorie ON prawa_jazdy_kategorie;

CREATE TRIGGER pj_kategorie BEFORE INSERT OR UPDATE ON prawa_jazdy_kategorie
FOR EACH ROW EXECUTE PROCEDURE pj_kategorie();

--sprawdzenie czy jak dodajemy kogos do tabeli prawa jazdy to czy on wczesniej zdal egzamin wogole
CREATE OR REPLACE FUNCTION czy_zdal() RETURNS trigger AS $$
BEGIN
	IF NOT EXISTS(
	SELECT *
	FROM egzaminy NATURAL JOIN wyniki_egzaminów
	WHERE id_kierowcy = NEW.id_właściciela
	AND typ = 'praktyka' AND wynik =  'zdał'
	AND data_przeprowadzenia <= NEW.data_wydania)
	THEN 
		RAISE EXCEPTION 'Ta osoba nie zdała prawa jazdy jeszcze';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS czy_zdal ON prawa_jazdy;

CREATE TRIGGER czy_zdal BEFORE INSERT OR UPDATE ON prawa_jazdy
FOR EACH ROW EXECUTE PROCEDURE czy_zdal();

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

	RETURN COALESCE(nr, 'brak');
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

	RETURN COALESCE(nr,'brak');
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
SELECT COALESCE(SUM(punkty_karne),0)
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
INNER JOIN marka_model
ON marka_model.id_marka_model = pojazdy.id_marka_model
GROUP BY marka, model;

--statystyki pojazdow po roku rejestracji 
DROP VIEW IF EXISTS statystyki_pojazdow_rokRejestracji;

CREATE OR REPLACE VIEW statystyki_pojazdow_rokRejestracji
AS
SELECT EXTRACT(YEAR FROM data_rejestracji) AS rok, COUNT(id_pojazdu) AS ilosc
FROM pojazdy
GROUP BY rok
ORDER BY rok;

--stattystyki po typie pojazdu
DROP VIEW IF EXISTS statystyki_pojazdow_typ;

CREATE OR REPLACE VIEW statystyki_pojazdow_typ
AS
SELECT typ, COUNT(id_pojazdu)
FROM pojazdy
GROUP BY typ
ORDER BY typ;

--statystyki zdawalnosci egzaminow
DROP VIEW IF EXISTS statystyki_zdawalnosci_egzaminow;

CREATE OR REPLACE VIEW statystyki_zdawalnosci_egzaminow
AS
SELECT wynik, typ, COUNT(id_egzaminu)
FROM egzaminy
NATURAL JOIN wyniki_egzaminów
GROUP BY wynik, typ;

--liczba przystepujacych do egzaminow w poszczegolnych latach
DROP VIEW IF EXISTS statystyki_egzaminow_w_latach;

CREATE OR REPLACE VIEW statystyki_egzaminow_w_latach
AS
SELECT EXTRACT(YEAR FROM data_przeprowadzenia) AS rok, COUNT(id_egzaminu) AS ilosc
FROM egzaminy
NATURAL JOIN wyniki_egzaminów
GROUP BY rok
ORDER BY rok;

--ranking najlepszych egzaminatorów z najwieksza liczba zdjacych klientow
DROP VIEW IF EXISTS statystyki_egzaminatorow;

CREATE OR REPLACE VIEW statystyki_egzaminatorow
AS
SELECT egzaminatorzy.imię, egzaminatorzy.nazwisko,
COUNT(
CASE
	WHEN wynik = 'zdał' THEN 1
	ELSE NULL
END) AS ilu_zdalo
FROM egzaminy
NATURAL JOIN wyniki_egzaminów
NATURAL JOIN egzaminatorzy
GROUP BY egzaminatorzy.imię, egzaminatorzy.nazwisko
ORDER BY ilu_zdalo DESC, egzaminatorzy.nazwisko, egzaminatorzy.imię;

--ranking najlepszych osrodkow
DROP VIEW IF EXISTS statystyki_egzaminow_w_zaleznosci_od_osrodka;

CREATE OR REPLACE VIEW statystyki_egzaminow_w_zaleznosci_od_osrodka
AS
SELECT nazwa, CONCAT(ulice.ulica, ' ', ośrodki.nr_budynku, ' ', miejscowosci.nazwa, ' ', ośrodki.kod_pocztowy) AS adres, COUNT(
CASE WHEN wynik = 'zdał' THEN 1
ELSE NULL
END) AS zdało, COUNT(wynik) AS zdawało, ROUND(100 * COUNT(
CASE WHEN wynik = 'zdał' THEN 1
ELSE NULL
END)/COUNT(wynik)) AS efektywnosc
FROM ośrodki
NATURAL JOIN ulice 
NATURAL JOIN miejscowosci
NATURAL JOIN egzaminy
NATURAL JOIN wyniki_egzaminów
GROUP BY nazwa, adres
ORDER BY efektywnosc DESC, nazwa, 2;

--spis wykroczen danego kierowcy o id_k
DROP FUNCTION IF EXISTS spis_wykroczen_danego_kierowcy(integer);

CREATE OR REPLACE FUNCTION spis_wykroczen_danego_kierowcy(id_k INTEGER)
RETURNS SETOF text AS
$$
SELECT DISTINCT opis
FROM mandaty NATURAL JOIN wykroczenia
WHERE id_kierowcy = id_k;
$$ LANGUAGE sql;

--ranking kierowcow z najwieksza liczba mandatow
DROP VIEW IF EXISTS statystyki_mandatow_najniebezpieczniejsi_kierowcy;

CREATE OR REPLACE VIEW statystyki_mandatow_najniebezpieczniejsi_kierowcy
AS
SELECT imię, nazwisko, COUNT(id_mandatu) AS ilosc_mandatow,
SUM(punkty_karne) AS suma_punktow_karnych
FROM wykroczenia 
NATURAL JOIN mandaty
NATURAL JOIN kierowcy
GROUP BY imię, nazwisko
ORDER BY ilosc_mandatow DESC, suma_punktow_karnych DESC;

--ranking wykroczen
DROP VIEW IF EXISTS ranking_wykroczen;

CREATE OR REPLACE VIEW ranking_wykroczen
AS
SELECT opis, COUNT(id_mandatu) AS ilosc
FROM wykroczenia 
NATURAL JOIN mandaty
GROUP BY opis
ORDER BY ilosc DESC, opis;

--ranking kierowcow z najwiekszymi grzywnami
DROP VIEW IF EXISTS ranking_kierowcow_z_najwieksza_grzywna;

CREATE OR REPLACE VIEW ranking_kierowcow_z_najwieksza_grzywna
AS
SELECT imię, nazwisko, SUM(wysokość_grzywny) AS suma_grzywn
FROM wykroczenia 
NATURAL JOIN mandaty
NATURAL JOIN kierowcy
GROUP BY imię, nazwisko
ORDER BY suma_grzywn DESC, nazwisko, imię;

--statystyki praw jazdy ze wzgledu na kategorie
DROP VIEW IF EXISTS statystyki_praw_jazdy;

CREATE OR REPLACE VIEW statystyki_praw_jazdy
AS
SELECT kategoria, COUNT(numer_prawa_jazdy) ilosc
FROM prawa_jazdy 
INNER JOIN prawa_jazdy_kategorie
ON prawa_jazdy_kategorie.id_kategoria = prawa_jazdy.id_kategoria
GROUP BY kategoria
ORDER BY ilosc DESC, kategoria;

COMMIT;
