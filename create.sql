BEGIN;
DROP TYPE IF EXISTS typ_kierownicy CASCADE;
DROP TYPE IF EXISTS typ_wlasciciela CASCADE;
DROP TABLE IF EXISTS pojazdy CASCADE;
DROP TABLE IF EXISTS kierowcy CASCADE;
DROP TABLE IF EXISTS kierowcy_pojazdy CASCADE;
DROP TABLE IF EXISTS prawa_jazdy CASCADE;
DROP TABLE IF EXISTS marka_model CASCADE;
DROP TABLE IF EXISTS prawa_jazdy_kategorie CASCADE;
DROP TYPE IF EXISTS typ_egzaminu CASCADE;
DROP TABLE IF EXISTS wyniki_egzaminów CASCADE;
DROP TYPE IF EXISTS wynik_egzaminu CASCADE;
DROP TABLE IF EXISTS egzaminatorzy CASCADE;
DROP TABLE IF EXISTS miejscowosc CASCADE;
DROP TABLE IF EXISTS egzaminy CASCADE;
DROP TABLE IF EXISTS osrodki CASCADE;
DROP TABLE IF EXISTS mandaty CASCADE;
DROP TABLE IF EXISTS model CASCADE;
DROP TABLE IF EXISTS marka CASCADE;
DROP TABLE IF EXISTS mandaty_wystawiajacy CASCADE;
DROP TABLE IF EXISTS prawa_jazdy_kategorie_praw_jazdy CASCADE;
DROP TABLE IF EXISTS wykroczenia CASCADE;
DROP TABLE IF EXISTS firma CASCADE;
DROP TABLE IF EXISTS sposob_zasilania CASCADE;
DROP TABLE IF EXISTS historia_wlascicieli CASCADE;
DROP TABLE IF EXISTS historia_przegladow_technicznych CASCADE;
DROP TABLE IF EXISTS pojazdy_kierowcy CASCADE;

CREATE TABLE miejscowosc (
  id_miejscowosc SERIAL NOT NULL PRIMARY KEY,
  nazwa TEXT NOT NULL
);

CREATE TABLE sposob_zasilania (
  id_sposob SERIAL NOT NULL PRIMARY KEY,
  nazwa     TEXT --gaz, benzyna etc
);

CREATE TYPE TYP_KIEROWNICY AS ENUM ('po prawej', 'po  lewej');

CREATE TYPE TYP_WLASCICIELA AS ENUM ('firma', 'osoba', 'brak');

CREATE TABLE marka (
  id_marka         SERIAL         NOT NULL PRIMARY KEY,
  marka            TEXT
);

CREATE TABLE model (
  id_modelu        SERIAL NOT NULL PRIMARY KEY,
  id_marki         INT NOT NULL REFERENCES marka(id_marka),
  model            TEXT,
  sposob_zasilania INT REFERENCES sposob_zasilania (id_sposob),
  liczba_miejsc    INT            NOT NULL,
  typ_kierownicy   TYP_KIEROWNICY NOT NULL
);

CREATE TABLE pojazdy (
  id_pojazdu       SERIAL PRIMARY KEY,
  nr_rejestracyjny CHAR(7) UNIQUE,
  numer_vin        CHAR(17),
  data_rejestracji DATE NOT NULL,
  id_model         INT NOT NULL REFERENCES model(id_modelu),
  typ              TEXT,
  kraj_produkcji   TEXT,
  waga_samochodu   NUMERIC
);

CREATE TABLE historia_przegladow_technicznych (
  nr_pojazdu       INT NOT NULL REFERENCES pojazdy (id_pojazdu),
  data_przegladu   TIMESTAMP WITHOUT TIME ZONE,
  data_wygasniecia TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE firma (
  id_firmy        SERIAL NOT NULL PRIMARY KEY,
  NIP             CHAR(10), --bedzie trigger
  REGON           CHAR(9), -- tez bedzie
  numerKRS        TEXT,
  nazwa_firmy     TEXT   NOT NULL,
  email           TEXT, /*CHECK*/
  nr_telefonu     CHAR(9),
  ulica           TEXT,
  nr_budynku      TEXT,
  kod_pocztowy    TEXT,
  id_miejscowosc  INT REFERENCES miejscowosc(id_miejscowosc)
);

CREATE TABLE kierowcy (
  id_kierowcy     SERIAL PRIMARY KEY,
  PESEL           CHAR(11)    NOT NULL UNIQUE,
  imie            VARCHAR(50) NOT NULL,
  nazwisko        VARCHAR(50) NOT NULL,
  plec            CHAR(1)     NOT NULL CHECK (plec = 'K' OR plec = 'M'),
  email           TEXT, /*CHECK*/
  nr_telefonu     CHAR(9),
  ulica           TEXT,
  nr_domu         TEXT,
  kod_pocztowy    TEXT,
  id_miejscowosc  INT REFERENCES miejscowosc(id_miejscowosc)
);

CREATE TABLE historia_wlascicieli (
  id_pojazdu      INT             NOT NULL REFERENCES pojazdy (id_pojazdu),
  typ_wlasciciela TYP_WLASCICIELA NOT NULL,
  id_firmy		  INT             REFERENCES firma(id_firmy),
  id_kierowcy	  INTEGER		  REFERENCES kierowcy(id_kierowcy),
  od_kiedy        TIMESTAMP WITHOUT TIME ZONE,
  do_kiedy        TIMESTAMP WITHOUT TIME ZONE
  --jezeli typ wlascciela to forma to id_wlasciciela wskazuje na firme
  --w tabeli firmy a jezeli wlasciciel to osoba to jest ona w tabeli kierowcy
  --i wtedy id wlasciciela pochodzi z tamtej tabeli
  --calosc bedzie obieta triggerem przy wstawianiu etc czy wszystko poprawnie
);

CREATE TABLE pojazdy_kierowcy(
  id_kierowcy	  INT REFERENCES kierowcy(id_kierowcy),
  id_pojazdu	  INT REFERENCES pojazdy(id_pojazdu)
);

CREATE TABLE prawa_jazdy_kategorie (
  id_kategoria SERIAL NOT NULL PRIMARY KEY,
  kategoria    TEXT
);

CREATE TABLE prawa_jazdy (
  numer_prawa_jazdy TEXT PRIMARY KEY,
  id_wlasciciela    INT REFERENCES kierowcy (id_kierowcy),
  data_wydania      DATE NOT NULL,
  miedzynarodowe    BOOL NOT NULL
);

CREATE TABLE prawa_jazdy_kategorie_praw_jazdy(
  id_prawa_jazdy    TEXT NOT NULL REFERENCES prawa_jazdy(numer_prawa_jazdy),
  id_kategoria      INT NOT NULL REFERENCES prawa_jazdy_kategorie(id_kategoria),
  data_wygasniecia  TIMESTAMP WITHOUT TIME ZONE
);

CREATE TYPE TYP_EGZAMINU AS ENUM ('teoria', 'praktyka');

CREATE TABLE egzaminatorzy (
  id_egzaminatora SERIAL PRIMARY KEY,
  imie            VARCHAR(50) NOT NULL,
  nazwisko        VARCHAR(50) NOT NULL,
  numer_licencji  TEXT
);

CREATE TABLE osrodki (
  id_osrodka      SERIAL PRIMARY KEY,
  nazwa           TEXT NOT NULL,
  ulica           TEXT,
  nr_budynku      TEXT,
  kod_pocztowy    TEXT,
  id_miejscowosc  INT REFERENCES miejscowosc(id_miejscowosc)
);

CREATE TYPE WYNIK_EGZAMINU AS ENUM ('zdal', 'nie zdal', 'nie stawil sie');

CREATE TABLE egzaminy (
  id_egzaminu          SERIAL PRIMARY KEY,
  data_przeprowadzenia DATE         NOT NULL,
  typ                  TYP_EGZAMINU NOT NULL,
  id_egzaminatora      INT          NOT NULL REFERENCES egzaminatorzy NOT NULL,
  id_osrodka           INT          NOT NULL REFERENCES osrodki (id_osrodka),
  id_kategoria         INT          NOT NULL REFERENCES prawa_jazdy_kategorie (id_kategoria),
  /*id_zdajacego,
  wynik - enum zdal, nie zdal, nie stawil sie, przeniesiony,...
  wynik punktowy
  osobna tabela 1 egzamin wielu zdajacych*/
  id_kierowcy INT REFERENCES kierowcy NOT NULL,
  wynik       WYNIK_EGZAMINU          NOT NULL
);

CREATE TABLE mandaty_wystawiajacy (
  id_wstawiajacego SERIAL PRIMARY KEY,
  imie             VARCHAR(50) NOT NULL,
  nazwisko         VARCHAR(50) NOT NULL
);

CREATE TABLE wykroczenia (
  id_wykroczenia   SERIAL PRIMARY KEY,
  opis             TEXT,
  wysokosc_grzywny NUMERIC(7, 2),
  punkty_karne     NUMERIC(2) NOT NULL
);

CREATE TABLE mandaty (
  id_mandatu        SERIAL PRIMARY KEY,
  id_kierowcy       INT REFERENCES kierowcy                                NOT NULL,
  id_wystawiajacego INT REFERENCES mandaty_wystawiajacy (id_wstawiajacego) NOT NULL,
  id_wykroczenia    INT REFERENCES wykroczenia                             NOT NULL,
  data_wystawienia  TIMESTAMP WITHOUT TIME ZONE
);

--Sprawdzanie poprawnosci wprowadzanego numeru pesel
CREATE OR REPLACE FUNCTION pesel_check()
  RETURNS TRIGGER AS $$
BEGIN
  IF LENGTH(NEW.pesel) < 11
  THEN
    RAISE EXCEPTION 'Niepoprawny PESEL';
  END IF;
  IF (((CAST(substring(NEW.pesel, 1, 1) AS INT)) * 1 +
       (CAST(substring(NEW.pesel, 2, 1) AS INT)) * 3 +
       (CAST(substring(NEW.pesel, 3, 1) AS INT)) * 7 +
       (CAST(substring(NEW.pesel, 4, 1) AS INT)) * 9 +
       (CAST(substring(NEW.pesel, 5, 1) AS INT)) * 1 +
       (CAST(substring(NEW.pesel, 6, 1) AS INT)) * 3 +
       (CAST(substring(NEW.pesel, 7, 1) AS INT)) * 7 +
       (CAST(substring(NEW.pesel, 8, 1) AS INT)) * 9 +
       (CAST(substring(NEW.pesel, 9, 1) AS INT)) * 1 +
       (CAST(substring(NEW.pesel, 10, 1) AS INT)) * 3 +
       (CAST(substring(NEW.pesel, 11, 1) AS INT)) * 1) % 10 <> 0)
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
CREATE OR REPLACE FUNCTION wykroczenia_check()
  RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.punkty_karne > 24 OR NEW.punkty_karne < 0)
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
CREATE OR REPLACE FUNCTION prawa_jazdy_check()
  RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS(SELECT numer_prawa_jazdy
            FROM prawa_jazdy
            WHERE id_wlasciciela = NEW.id_wlasciciela
                  AND miedzynarodowe != NEW.miedzynarodowe)
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
CREATE OR REPLACE FUNCTION pj_kategorie()
  RETURNS TRIGGER AS $$
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
CREATE OR REPLACE FUNCTION czy_zdal()
  RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS(
      SELECT *
      FROM egzaminy
      WHERE id_kierowcy = NEW.id_wlasciciela
            AND typ = 'praktyka' AND wynik = 'zdal'
            AND data_przeprowadzenia <= NEW.data_wydania)
  THEN
    RAISE EXCEPTION 'Ta osoba nie zdala prawa jazdy jeszcze';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS czy_zdal ON prawa_jazdy;

CREATE TRIGGER czy_zdal BEFORE INSERT OR UPDATE ON prawa_jazdy
FOR EACH ROW EXECUTE PROCEDURE czy_zdal();

--wypis id pojazdow ktorych wlascicielem jest kierowca o id_k
DROP FUNCTION IF EXISTS pojazdy( INTEGER );

CREATE OR REPLACE FUNCTION pojazdy(id_k INT)
  RETURNS SETOF INT AS
$$
SELECT id_pojazdu
FROM historia_wlascicieli
WHERE (typ_wlasciciela = 'osoba' AND id_kierowcy = id_k AND od_kiedy < now() AND do_kiedy > now());
$$ LANGUAGE SQL;

--wypis numeru prawa jazdy kierowcy o id_k
DROP FUNCTION IF EXISTS nr_prawa_jazdy( INTEGER );

CREATE OR REPLACE FUNCTION nr_prawa_jazdy(id_k INT)
  RETURNS TEXT AS
$$
DECLARE
  nr TEXT;
BEGIN
  nr = (SELECT numer_prawa_jazdy
        FROM prawa_jazdy
        WHERE id_wlasciciela = id_k
        LIMIT 1);

  RETURN COALESCE(nr, 'brak');
END;
$$ LANGUAGE plpgsql;

--id miedzynarodowego prawa jazdy kierowcy o id_k
DROP FUNCTION IF EXISTS nr_prawa_jazdy_M( INTEGER );

CREATE OR REPLACE FUNCTION nr_prawa_jazdy_M(id_k INT)
  RETURNS TEXT AS
$$
DECLARE
  nr TEXT;
BEGIN
  nr = (SELECT numer_prawa_jazdy
        FROM prawa_jazdy
        WHERE id_wlasciciela = id_k AND miedzynarodowe IS TRUE
        LIMIT 1);

  RETURN COALESCE(nr, 'brak');
END;
$$ LANGUAGE plpgsql;

--ilosc mandatow kierowcy o id_k
DROP FUNCTION IF EXISTS ilosc_mandatow( INTEGER );

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
DROP FUNCTION IF EXISTS ile_punktow( INTEGER );

CREATE OR REPLACE FUNCTION ile_punktow(id_k INT)
  RETURNS NUMERIC AS
$$
SELECT COALESCE(SUM(punkty_karne), 0)
FROM (
       SELECT punkty_karne
       FROM mandaty
         INNER JOIN wykroczenia ON mandaty.id_wykroczenia = wykroczenia.id_wykroczenia
       WHERE mandaty.id_kierowcy = id_k) AS tab;
$$ LANGUAGE SQL;

--ilosc podejsc do egzaminu na prawo jazdy kierowcy o id_k
DROP FUNCTION IF EXISTS ilosc_egzaminow( INTEGER );

CREATE OR REPLACE FUNCTION ilosc_egzaminow(id_k INT)
  RETURNS INTEGER AS
$$
DECLARE
  nr INTEGER;
BEGIN
  nr = (
    SELECT COUNT(id_egzaminu)
    FROM egzaminy
    WHERE id_kierowcy = id_k);

  RETURN nr;
END;
$$ LANGUAGE plpgsql;

--id ostatniego egzaminu danego kierowcy o id_k
DROP FUNCTION IF EXISTS ostatni_egzamin( INTEGER );

CREATE OR REPLACE FUNCTION ostatni_egzamin(id_k INT)
  RETURNS INTEGER AS
$$
DECLARE
  nr INTEGER;
BEGIN
  nr = (
    SELECT egzaminy.id_egzaminu
    FROM egzaminy
    WHERE id_kierowcy = id_k
    ORDER BY data_przeprowadzenia DESC
    LIMIT 1);

  RETURN nr;
END;
$$ LANGUAGE plpgsql;

--dla danego numeru rejestracji wypisuje imiona_i_naziwska_osob_z_bazy_ktorego maja go przypisanego
DROP FUNCTION IF EXISTS imie_i_nazwisko_wlasciciela_samochodu( CHAR(7) );

--statystki ile jest w bazie pojazdow jakiej marki i modelu
DROP VIEW IF EXISTS statystyki_pojazdow_markaModel;

CREATE OR REPLACE VIEW statystyki_pojazdow_markaModel
AS
  SELECT
    marka,
    model,
    COUNT(id_pojazdu)
  FROM pojazdy
    INNER JOIN model
      ON model.id_modelu = pojazdy.id_model
        INNER JOIN marka
          ON marka.id_marka = model.id_marki
  GROUP BY marka, model;

--statystyki pojazdow po roku rejestracji 
DROP VIEW IF EXISTS statystyki_pojazdow_rokRejestracji;

CREATE OR REPLACE VIEW statystyki_pojazdow_rokRejestracji
AS
  SELECT
    EXTRACT(YEAR FROM data_rejestracji) AS rok,
    COUNT(id_pojazdu)                   AS ilosc
  FROM pojazdy
  GROUP BY rok
  ORDER BY rok;

--stattystyki po typie pojazdu
DROP VIEW IF EXISTS statystyki_pojazdow_typ;

CREATE OR REPLACE VIEW statystyki_pojazdow_typ
AS
  SELECT
    typ,
    COUNT(id_pojazdu)
  FROM pojazdy
  GROUP BY typ
  ORDER BY typ;

--statystyki zdawalnosci egzaminow
DROP VIEW IF EXISTS statystyki_zdawalnosci_egzaminow;

CREATE OR REPLACE VIEW statystyki_zdawalnosci_egzaminow
AS
  SELECT
    wynik,
    typ,
    COUNT(id_egzaminu)
  FROM egzaminy
  GROUP BY wynik, typ;

--liczba przystepujacych do egzaminow w poszczegolnych latach
DROP VIEW IF EXISTS statystyki_egzaminow_w_latach;

CREATE OR REPLACE VIEW statystyki_egzaminow_w_latach
AS
  SELECT
    EXTRACT(YEAR FROM data_przeprowadzenia) AS rok,
    COUNT(id_egzaminu)                      AS ilosc
  FROM egzaminy
  GROUP BY rok
  ORDER BY rok;

--ranking najlepszych egzaminatorów z najwieksza liczba zdjacych klientow
DROP VIEW IF EXISTS statystyki_egzaminatorow;

CREATE OR REPLACE VIEW statystyki_egzaminatorow
AS
  SELECT
    egzaminatorzy.imie,
    egzaminatorzy.nazwisko,
    COUNT(
        CASE
        WHEN wynik = 'zdal'
          THEN 1
        ELSE NULL
        END) AS ilu_zdalo
  FROM egzaminy
    NATURAL JOIN egzaminatorzy
  GROUP BY egzaminatorzy.imie, egzaminatorzy.nazwisko
  ORDER BY ilu_zdalo DESC, egzaminatorzy.nazwisko, egzaminatorzy.imie;

--ranking najlepszych osrodkow
DROP VIEW IF EXISTS statystyki_egzaminow_w_zaleznosci_od_osrodka;

CREATE OR REPLACE VIEW statystyki_egzaminow_w_zaleznosci_od_osrodka
AS
  SELECT
    nazwa,
    CONCAT(ulica, ' ', osrodki.nr_budynku, ' ', miejscowosc.nazwa, ' ', osrodki.kod_pocztowy) AS adres,
    COUNT(
        CASE WHEN wynik = 'zdal'
          THEN 1
        ELSE NULL
        END)                                                                                         AS zdalo,
    COUNT(wynik)                                                                                     AS zdawalo,
    ROUND(100 * COUNT(
        CASE WHEN wynik = 'zdal'
          THEN 1
        ELSE NULL
        END) / COUNT(wynik))                                                                         AS efektywnosc
  FROM osrodki
    NATURAL JOIN egzaminy
    NATURAL JOIN miejscowosc
  GROUP BY nazwa, adres
  ORDER BY efektywnosc DESC, nazwa, 2;

--spis wykroczen danego kierowcy o id_k
DROP FUNCTION IF EXISTS spis_wykroczen_danego_kierowcy( INTEGER );

CREATE OR REPLACE FUNCTION spis_wykroczen_danego_kierowcy(id_k INTEGER)
  RETURNS SETOF TEXT AS
$$
SELECT DISTINCT opis
FROM mandaty
  NATURAL JOIN wykroczenia
WHERE id_kierowcy = id_k;
$$ LANGUAGE SQL;

--ranking kierowcow z najwieksza liczba mandatow
DROP VIEW IF EXISTS statystyki_mandatow_najniebezpieczniejsi_kierowcy;

CREATE OR REPLACE VIEW statystyki_mandatow_najniebezpieczniejsi_kierowcy
AS
  SELECT
    imie,
    nazwisko,
    COUNT(id_mandatu) AS ilosc_mandatow,
    SUM(punkty_karne) AS suma_punktow_karnych
  FROM wykroczenia
    NATURAL JOIN mandaty
    NATURAL JOIN kierowcy
  GROUP BY imie, nazwisko
  ORDER BY ilosc_mandatow DESC, suma_punktow_karnych DESC;

--ranking wykroczen
DROP VIEW IF EXISTS ranking_wykroczen;

CREATE OR REPLACE VIEW ranking_wykroczen
AS
  SELECT
    opis,
    COUNT(id_mandatu) AS ilosc
  FROM wykroczenia
    NATURAL JOIN mandaty
  GROUP BY opis
  ORDER BY ilosc DESC, opis;

--ranking kierowcow z najwiekszymi grzywnami
DROP VIEW IF EXISTS ranking_kierowcow_z_najwieksza_grzywna;

CREATE OR REPLACE VIEW ranking_kierowcow_z_najwieksza_grzywna
AS
  SELECT
    imie,
    nazwisko,
    SUM(wysokosc_grzywny) AS suma_grzywn
  FROM wykroczenia
    NATURAL JOIN mandaty
    NATURAL JOIN kierowcy
  GROUP BY imie, nazwisko
  ORDER BY suma_grzywn DESC, nazwisko, imie;

--statystyki praw jazdy ze wzgledu na kategorie
DROP VIEW IF EXISTS statystyki_praw_jazdy;

CREATE OR REPLACE VIEW statystyki_praw_jazdy
AS
  SELECT
    kategoria,
    COUNT(numer_prawa_jazdy) ilosc
  FROM prawa_jazdy
    NATURAL JOIN prawa_jazdy_kategorie_praw_jazdy
    NATURAL JOIN  prawa_jazdy_kategorie
  GROUP BY kategoria
  ORDER BY ilosc DESC, kategoria;
END;
