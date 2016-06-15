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
                WHERE numer_prawa_jazdy = NEW.id_prawa_jazdy)
  THEN
    RAISE EXCEPTION 'Brak tego prawa jazdy w tabeli prawa jazdy';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS pj_kategorie ON prawa_jazdy_kategorie_praw_jazdy;

CREATE TRIGGER pj_kategorie BEFORE INSERT OR UPDATE ON prawa_jazdy_kategorie_praw_jazdy
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
    osrodki.nazwa,
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
    JOIN egzaminy
      ON osrodki.id_osrodka=egzaminy.id_osrodka
    JOIN miejscowosc
      ON osrodki.id_miejscowosc=miejscowosc.id_miejscowosc
  GROUP BY osrodki.nazwa, adres
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

--krotki
INSERT INTO miejscowosc VALUES (1, 'Wrocław');
INSERT INTO miejscowosc VALUES (2, 'Jelenia Góra');
INSERT INTO miejscowosc VALUES (3, 'Legnica');
INSERT INTO miejscowosc VALUES (4, 'Wałbrzych');
INSERT INTO miejscowosc VALUES (5, 'Bolesławiec');
INSERT INTO miejscowosc VALUES (6, 'Dzierżoniów');
INSERT INTO miejscowosc VALUES (7, 'Głogów');
INSERT INTO miejscowosc VALUES (8, 'Góra');
INSERT INTO miejscowosc VALUES (9, 'Jawor');
INSERT INTO miejscowosc VALUES (10, 'Jelenia Góra');
INSERT INTO miejscowosc VALUES (11, 'Kamienna Góra');
INSERT INTO miejscowosc VALUES (12, 'Kłodzko');
INSERT INTO miejscowosc VALUES (13, 'Legnica');
INSERT INTO miejscowosc VALUES (14, 'Lubań');
INSERT INTO miejscowosc VALUES (15, 'Lubin');
INSERT INTO miejscowosc VALUES (16, 'Lwówek Śląski');
INSERT INTO miejscowosc VALUES (17, 'Milicz');
INSERT INTO miejscowosc VALUES (18, 'Oleśnica');
INSERT INTO miejscowosc VALUES (19, 'Oława');
INSERT INTO miejscowosc VALUES (20, 'Polkowice');
INSERT INTO miejscowosc VALUES (21, 'Strzelin');
INSERT INTO miejscowosc VALUES (22, 'Środa Śląska');
INSERT INTO miejscowosc VALUES (23, 'Świdnica');
INSERT INTO miejscowosc VALUES (24, 'Trzebnica');
INSERT INTO miejscowosc VALUES (25, 'Wałbrzych');
INSERT INTO miejscowosc VALUES (26, 'Wołów');
INSERT INTO miejscowosc VALUES (27, 'Wrocław');
INSERT INTO miejscowosc VALUES (28, 'Ząbkowice Śląskie');
INSERT INTO miejscowosc VALUES (29, 'Zgorzelec');
INSERT INTO miejscowosc VALUES (30, 'Złotoryja');
INSERT INTO miejscowosc VALUES (31, 'Bydgoszcz');
INSERT INTO miejscowosc VALUES (32, 'Toruń');
INSERT INTO miejscowosc VALUES (33, 'Włocławek');
INSERT INTO miejscowosc VALUES (34, 'Grudziądz');
INSERT INTO miejscowosc VALUES (35, 'Aleksandrów Kujawski');
INSERT INTO miejscowosc VALUES (36, 'Brodnica');
INSERT INTO miejscowosc VALUES (37, 'Bydgoszcz');
INSERT INTO miejscowosc VALUES (38, 'Chełmno');
INSERT INTO miejscowosc VALUES (39, 'Golub-Dobrzyń');
INSERT INTO miejscowosc VALUES (40, 'Grudziądz');
INSERT INTO miejscowosc VALUES (41, 'Inowrocław');
INSERT INTO miejscowosc VALUES (42, 'Lipno');
INSERT INTO miejscowosc VALUES (43, 'Mogilno');
INSERT INTO miejscowosc VALUES (44, 'Nakło nad Notecią');
INSERT INTO miejscowosc VALUES (45, 'Radziejów');
INSERT INTO miejscowosc VALUES (46, 'Rypin');
INSERT INTO miejscowosc VALUES (47, 'Sępólno Krajeńskie');
INSERT INTO miejscowosc VALUES (48, 'Świecie');
INSERT INTO miejscowosc VALUES (49, 'Toruń');
INSERT INTO miejscowosc VALUES (50, 'Tuchola');
INSERT INTO miejscowosc VALUES (51, 'Wąbrzeźno');
INSERT INTO miejscowosc VALUES (52, 'Włocławek');
INSERT INTO miejscowosc VALUES (53, 'Żnin');
INSERT INTO miejscowosc VALUES (54, 'Lublin');
INSERT INTO miejscowosc VALUES (55, 'Biała Podlaska');
INSERT INTO miejscowosc VALUES (56, 'Chełm');
INSERT INTO miejscowosc VALUES (57, 'Zamość');
INSERT INTO miejscowosc VALUES (58, 'Biała Podlaska');
INSERT INTO miejscowosc VALUES (59, 'Biłgoraj');
INSERT INTO miejscowosc VALUES (60, 'Chełm');
INSERT INTO miejscowosc VALUES (61, 'Hrubieszów');
INSERT INTO miejscowosc VALUES (62, 'Janów Lubelski');
INSERT INTO miejscowosc VALUES (63, 'Krasnystaw');
INSERT INTO miejscowosc VALUES (64, 'Kraśnik');
INSERT INTO miejscowosc VALUES (65, 'Lubartów');
INSERT INTO miejscowosc VALUES (66, 'Lublin');
INSERT INTO miejscowosc VALUES (67, 'Łęczna');
INSERT INTO miejscowosc VALUES (68, 'Łuków');
INSERT INTO miejscowosc VALUES (69, 'Opole Lubelskie');
INSERT INTO miejscowosc VALUES (70, 'Parczew');
INSERT INTO miejscowosc VALUES (71, 'Puławy');
INSERT INTO miejscowosc VALUES (72, 'Radzyń Podlaski');
INSERT INTO miejscowosc VALUES (73, 'Ryki');
INSERT INTO miejscowosc VALUES (74, 'Świdnik');
INSERT INTO miejscowosc VALUES (75, 'Tomaszów Lubelski');
INSERT INTO miejscowosc VALUES (76, 'Włodawa');
INSERT INTO miejscowosc VALUES (77, 'Zamość');
INSERT INTO miejscowosc VALUES (78, 'Gorzów Wielkopolski');
INSERT INTO miejscowosc VALUES (79, 'Zielona Góra');
INSERT INTO miejscowosc VALUES (80, 'Gorzów Wielkopolski');
INSERT INTO miejscowosc VALUES (81, 'Krosno Odrzańskie');
INSERT INTO miejscowosc VALUES (82, 'Międzyrzecz');
INSERT INTO miejscowosc VALUES (83, 'Nowa Sól');
INSERT INTO miejscowosc VALUES (84, 'Słubice');
INSERT INTO miejscowosc VALUES (85, 'Strzelce Krajeńskie');
INSERT INTO miejscowosc VALUES (86, 'Sulęcin');
INSERT INTO miejscowosc VALUES (87, 'Świebodzin');
INSERT INTO miejscowosc VALUES (88, 'Wschowa');
INSERT INTO miejscowosc VALUES (89, 'Zielona Góra');
INSERT INTO miejscowosc VALUES (90, 'Żagań');
INSERT INTO miejscowosc VALUES (91, 'Żary');
INSERT INTO miejscowosc VALUES (92, 'Łódź');
INSERT INTO miejscowosc VALUES (93, 'Piotrków Trybunalski');
INSERT INTO miejscowosc VALUES (94, 'Skierniewice');
INSERT INTO miejscowosc VALUES (95, 'Bełchatów');
INSERT INTO miejscowosc VALUES (96, 'Brzeziny');
INSERT INTO miejscowosc VALUES (97, 'Kutno');
INSERT INTO miejscowosc VALUES (98, 'Łask');
INSERT INTO miejscowosc VALUES (99, 'Łęczyca');
INSERT INTO miejscowosc VALUES (100, 'Łowicz');
INSERT INTO miejscowosc VALUES (101, 'Łódź');
INSERT INTO miejscowosc VALUES (102, 'Opoczno');
INSERT INTO miejscowosc VALUES (103, 'Pabianice');
INSERT INTO miejscowosc VALUES (104, 'Pajęczno');
INSERT INTO miejscowosc VALUES (105, 'Piotrków Trybunalski');
INSERT INTO miejscowosc VALUES (106, 'Poddębice');
INSERT INTO miejscowosc VALUES (107, 'Radomsko');
INSERT INTO miejscowosc VALUES (108, 'Rawa Mazowiecka');
INSERT INTO miejscowosc VALUES (109, 'Sieradz');
INSERT INTO miejscowosc VALUES (110, 'Skierniewice');
INSERT INTO miejscowosc VALUES (111, 'Tomaszów Mazowiecki');
INSERT INTO miejscowosc VALUES (112, 'Wieluń');
INSERT INTO miejscowosc VALUES (113, 'Wieruszów');
INSERT INTO miejscowosc VALUES (114, 'Zduńska Wola');
INSERT INTO miejscowosc VALUES (115, 'Zgierz');
INSERT INTO miejscowosc VALUES (116, 'Kraków');
INSERT INTO miejscowosc VALUES (117, 'Nowy Sącz');
INSERT INTO miejscowosc VALUES (118, 'Tarnów');
INSERT INTO miejscowosc VALUES (119, 'Bochnia');
INSERT INTO miejscowosc VALUES (120, 'Brzesko');
INSERT INTO miejscowosc VALUES (121, 'Chrzanów');
INSERT INTO miejscowosc VALUES (122, 'Dąbrowa Tarnowska');
INSERT INTO miejscowosc VALUES (123, 'Gorlice');
INSERT INTO miejscowosc VALUES (124, 'Kraków');
INSERT INTO miejscowosc VALUES (125, 'Limanowa');
INSERT INTO miejscowosc VALUES (126, 'Miechów');
INSERT INTO miejscowosc VALUES (127, 'Myślenice');
INSERT INTO miejscowosc VALUES (128, 'Nowy Sącz');
INSERT INTO miejscowosc VALUES (129, 'Nowy Targ');
INSERT INTO miejscowosc VALUES (130, 'Olkusz');
INSERT INTO miejscowosc VALUES (131, 'Oświęcim');
INSERT INTO miejscowosc VALUES (132, 'Proszowice');
INSERT INTO miejscowosc VALUES (133, 'Sucha Beskidzka');
INSERT INTO miejscowosc VALUES (134, 'Tarnów');
INSERT INTO miejscowosc VALUES (135, 'Zakopane');
INSERT INTO miejscowosc VALUES (136, 'Wadowice');
INSERT INTO miejscowosc VALUES (137, 'Wieliczka');
INSERT INTO miejscowosc VALUES (138, 'Warszawa');
INSERT INTO miejscowosc VALUES (139, 'Ostrołęka');
INSERT INTO miejscowosc VALUES (140, 'Płock');
INSERT INTO miejscowosc VALUES (141, 'Radom');
INSERT INTO miejscowosc VALUES (142, 'Siedlce');
INSERT INTO miejscowosc VALUES (143, 'Białobrzegi');
INSERT INTO miejscowosc VALUES (144, 'Ciechanów');
INSERT INTO miejscowosc VALUES (145, 'Garwolin');
INSERT INTO miejscowosc VALUES (146, 'Gostynin');
INSERT INTO miejscowosc VALUES (147, 'Grodzisk Mazowiecki');
INSERT INTO miejscowosc VALUES (148, 'Grójec');
INSERT INTO miejscowosc VALUES (149, 'Kozienice');
INSERT INTO miejscowosc VALUES (150, 'Legionowo');
INSERT INTO miejscowosc VALUES (151, 'Lipsko');
INSERT INTO miejscowosc VALUES (152, 'Łosice');
INSERT INTO miejscowosc VALUES (153, 'Maków Mazowiecki');
INSERT INTO miejscowosc VALUES (154, 'Mińsk Mazowiecki');
INSERT INTO miejscowosc VALUES (155, 'Mława');
INSERT INTO miejscowosc VALUES (156, 'Nowy Dwór Mazowiecki');
INSERT INTO miejscowosc VALUES (157, 'Ostrołęka');
INSERT INTO miejscowosc VALUES (158, 'Ostrów Mazowiecka');
INSERT INTO miejscowosc VALUES (159, 'Otwock');
INSERT INTO miejscowosc VALUES (160, 'Piaseczno');
INSERT INTO miejscowosc VALUES (161, 'Płock');
INSERT INTO miejscowosc VALUES (162, 'Płońsk');
INSERT INTO miejscowosc VALUES (163, 'Pruszków');
INSERT INTO miejscowosc VALUES (164, 'Przasnysz');
INSERT INTO miejscowosc VALUES (165, 'Przysucha');
INSERT INTO miejscowosc VALUES (166, 'Pułtusk');
INSERT INTO miejscowosc VALUES (167, 'Radom');
INSERT INTO miejscowosc VALUES (168, 'Siedlce');
INSERT INTO miejscowosc VALUES (169, 'Sierpc');
INSERT INTO miejscowosc VALUES (170, 'Sochaczew');
INSERT INTO miejscowosc VALUES (171, 'Sokołów Podlaski');
INSERT INTO miejscowosc VALUES (172, 'Szydłowiec');
INSERT INTO miejscowosc VALUES (173, 'Ożarów Mazowiecki');
INSERT INTO miejscowosc VALUES (174, 'Węgrów');
INSERT INTO miejscowosc VALUES (175, 'Wołomin');
INSERT INTO miejscowosc VALUES (176, 'Wyszków');
INSERT INTO miejscowosc VALUES (177, 'Zwoleń');
INSERT INTO miejscowosc VALUES (178, 'Żuromin');
INSERT INTO miejscowosc VALUES (179, 'Żyrardów');
INSERT INTO miejscowosc VALUES (180, 'Opole');
INSERT INTO miejscowosc VALUES (181, 'Brzeg');
INSERT INTO miejscowosc VALUES (182, 'Głubczyce');
INSERT INTO miejscowosc VALUES (183, 'Kędzierzyn-Koźle');
INSERT INTO miejscowosc VALUES (184, 'Kluczbork');
INSERT INTO miejscowosc VALUES (185, 'Krapkowice');
INSERT INTO miejscowosc VALUES (186, 'Namysłów');
INSERT INTO miejscowosc VALUES (187, 'Nysa');
INSERT INTO miejscowosc VALUES (188, 'Olesno');
INSERT INTO miejscowosc VALUES (189, 'Opole');
INSERT INTO miejscowosc VALUES (190, 'Prudnik');
INSERT INTO miejscowosc VALUES (191, 'Strzelce Opolskie');
INSERT INTO miejscowosc VALUES (192, 'Rzeszów');
INSERT INTO miejscowosc VALUES (193, 'Krosno');
INSERT INTO miejscowosc VALUES (194, 'Przemyśl');
INSERT INTO miejscowosc VALUES (195, 'Tarnobrzeg');
INSERT INTO miejscowosc VALUES (196, 'Ustrzyki Dolne');
INSERT INTO miejscowosc VALUES (197, 'Brzozów');
INSERT INTO miejscowosc VALUES (198, 'Dębica');
INSERT INTO miejscowosc VALUES (199, 'Jarosław');
INSERT INTO miejscowosc VALUES (200, 'Jasło');
INSERT INTO miejscowosc VALUES (201, 'Kolbuszowa');
INSERT INTO miejscowosc VALUES (202, 'Krosno');
INSERT INTO miejscowosc VALUES (203, 'Lesko');
INSERT INTO miejscowosc VALUES (204, 'Leżajsk');
INSERT INTO miejscowosc VALUES (205, 'Lubaczów');
INSERT INTO miejscowosc VALUES (206, 'Łańcut');
INSERT INTO miejscowosc VALUES (207, 'Mielec');
INSERT INTO miejscowosc VALUES (208, 'Nisko');
INSERT INTO miejscowosc VALUES (209, 'Przemyśl');
INSERT INTO miejscowosc VALUES (210, 'Przeworsk');
INSERT INTO miejscowosc VALUES (211, 'Ropczyce');
INSERT INTO miejscowosc VALUES (212, 'Rzeszów');
INSERT INTO miejscowosc VALUES (213, 'Sanok');
INSERT INTO miejscowosc VALUES (214, 'Stalowa Wola');
INSERT INTO miejscowosc VALUES (215, 'Strzyżów');
INSERT INTO miejscowosc VALUES (216, 'Tarnobrzeg');
INSERT INTO miejscowosc VALUES (217, 'Białystok');
INSERT INTO miejscowosc VALUES (218, 'Łomża');
INSERT INTO miejscowosc VALUES (219, 'Suwałki');
INSERT INTO miejscowosc VALUES (220, 'Augustów');
INSERT INTO miejscowosc VALUES (221, 'Białystok');
INSERT INTO miejscowosc VALUES (222, 'Bielsk Podlaski');
INSERT INTO miejscowosc VALUES (223, 'Grajewo');
INSERT INTO miejscowosc VALUES (224, 'Hajnówka');
INSERT INTO miejscowosc VALUES (225, 'Kolno');
INSERT INTO miejscowosc VALUES (226, 'Łomża');
INSERT INTO miejscowosc VALUES (227, 'Mońki');
INSERT INTO miejscowosc VALUES (228, 'Sejny');
INSERT INTO miejscowosc VALUES (229, 'Siemiatycze');
INSERT INTO miejscowosc VALUES (230, 'Sokółka');
INSERT INTO miejscowosc VALUES (231, 'Suwałki');
INSERT INTO miejscowosc VALUES (232, 'Wysokie Mazowieckie');
INSERT INTO miejscowosc VALUES (233, 'Zambrów');
INSERT INTO miejscowosc VALUES (234, 'Gdańsk');
INSERT INTO miejscowosc VALUES (235, 'Gdynia');
INSERT INTO miejscowosc VALUES (236, 'Słupsk');
INSERT INTO miejscowosc VALUES (237, 'Sopot');
INSERT INTO miejscowosc VALUES (238, 'Bytów');
INSERT INTO miejscowosc VALUES (239, 'Chojnice');
INSERT INTO miejscowosc VALUES (240, 'Człuchów');
INSERT INTO miejscowosc VALUES (241, 'Kartuzy');
INSERT INTO miejscowosc VALUES (242, 'Kościerzyna');
INSERT INTO miejscowosc VALUES (243, 'Kwidzyn');
INSERT INTO miejscowosc VALUES (244, 'Lębork');
INSERT INTO miejscowosc VALUES (245, 'Malbork');
INSERT INTO miejscowosc VALUES (246, 'Nowy Dwór Gdański');
INSERT INTO miejscowosc VALUES (247, 'Pruszcz Gdański');
INSERT INTO miejscowosc VALUES (248, 'Puck');
INSERT INTO miejscowosc VALUES (249, 'Słupsk');
INSERT INTO miejscowosc VALUES (250, 'Starogard Gdański');
INSERT INTO miejscowosc VALUES (251, 'Sztum');
INSERT INTO miejscowosc VALUES (252, 'Tczew');
INSERT INTO miejscowosc VALUES (253, 'Wejherowo');
INSERT INTO miejscowosc VALUES (254, 'Katowice');
INSERT INTO miejscowosc VALUES (255, 'Bielsko-Biała');
INSERT INTO miejscowosc VALUES (256, 'Bytom');
INSERT INTO miejscowosc VALUES (257, 'Chorzów');
INSERT INTO miejscowosc VALUES (258, 'Częstochowa');
INSERT INTO miejscowosc VALUES (259, 'Dąbrowa Górnicza');
INSERT INTO miejscowosc VALUES (260, 'Gliwice');
INSERT INTO miejscowosc VALUES (261, 'Jastrzębie-Zdrój');
INSERT INTO miejscowosc VALUES (262, 'Jaworzno');
INSERT INTO miejscowosc VALUES (263, 'Mysłowice');
INSERT INTO miejscowosc VALUES (264, 'Piekary Śląskie');
INSERT INTO miejscowosc VALUES (265, 'Ruda Śląska');
INSERT INTO miejscowosc VALUES (266, 'Rybnik');
INSERT INTO miejscowosc VALUES (267, 'Siemianowice Śląskie');
INSERT INTO miejscowosc VALUES (268, 'Sosnowiec');
INSERT INTO miejscowosc VALUES (269, 'Świętochłowice');
INSERT INTO miejscowosc VALUES (270, 'Tychy');
INSERT INTO miejscowosc VALUES (271, 'Zabrze');
INSERT INTO miejscowosc VALUES (272, 'Żory');
INSERT INTO miejscowosc VALUES (273, 'Będzin');
INSERT INTO miejscowosc VALUES (274, 'Bielsko-Biała');
INSERT INTO miejscowosc VALUES (275, 'Bieruń');
INSERT INTO miejscowosc VALUES (276, 'Cieszyn');
INSERT INTO miejscowosc VALUES (277, 'Częstochowa');
INSERT INTO miejscowosc VALUES (278, 'Gliwice');
INSERT INTO miejscowosc VALUES (279, 'Kłobuck');
INSERT INTO miejscowosc VALUES (280, 'Lubliniec');
INSERT INTO miejscowosc VALUES (281, 'Mikołów');
INSERT INTO miejscowosc VALUES (282, 'Myszków');
INSERT INTO miejscowosc VALUES (283, 'Pszczyna');
INSERT INTO miejscowosc VALUES (284, 'Racibórz');
INSERT INTO miejscowosc VALUES (285, 'Rybnik');
INSERT INTO miejscowosc VALUES (286, 'Tarnowskie Góry');
INSERT INTO miejscowosc VALUES (287, 'Wodzisław Śląski');
INSERT INTO miejscowosc VALUES (288, 'Zawiercie');
INSERT INTO miejscowosc VALUES (289, 'Żywiec');
INSERT INTO miejscowosc VALUES (290, 'Kielce');
INSERT INTO miejscowosc VALUES (291, 'Busko-Zdrój');
INSERT INTO miejscowosc VALUES (292, 'Jędrzejów');
INSERT INTO miejscowosc VALUES (293, 'Kazimierza Wielka');
INSERT INTO miejscowosc VALUES (294, 'Kielce');
INSERT INTO miejscowosc VALUES (295, 'Końskie');
INSERT INTO miejscowosc VALUES (296, 'Opatów');
INSERT INTO miejscowosc VALUES (297, 'Ostrowiec Świętokrzyski');
INSERT INTO miejscowosc VALUES (298, 'Pińczów');
INSERT INTO miejscowosc VALUES (299, 'Sandomierz');
INSERT INTO miejscowosc VALUES (300, 'Skarżysko-Kamienna');
INSERT INTO miejscowosc VALUES (301, 'Starachowice');
INSERT INTO miejscowosc VALUES (302, 'Staszów');
INSERT INTO miejscowosc VALUES (303, 'Włoszczowa');
INSERT INTO miejscowosc VALUES (304, 'Olsztyn');
INSERT INTO miejscowosc VALUES (305, 'Elbląg');
INSERT INTO miejscowosc VALUES (306, 'Bartoszyce');
INSERT INTO miejscowosc VALUES (307, 'Braniewo');
INSERT INTO miejscowosc VALUES (308, 'Działdowo');
INSERT INTO miejscowosc VALUES (309, 'Elbląg');
INSERT INTO miejscowosc VALUES (310, 'Ełk');
INSERT INTO miejscowosc VALUES (311, 'Giżycko');
INSERT INTO miejscowosc VALUES (312, 'Gołdap');
INSERT INTO miejscowosc VALUES (313, 'Iława');
INSERT INTO miejscowosc VALUES (314, 'Kętrzyn');
INSERT INTO miejscowosc VALUES (315, 'Lidzbark Warmiński');
INSERT INTO miejscowosc VALUES (316, 'Mrągowo');
INSERT INTO miejscowosc VALUES (317, 'Nidzica');
INSERT INTO miejscowosc VALUES (318, 'Nowe Miasto Lubawskie');
INSERT INTO miejscowosc VALUES (319, 'Olecko');
INSERT INTO miejscowosc VALUES (320, 'Olsztyn');
INSERT INTO miejscowosc VALUES (321, 'Ostróda');
INSERT INTO miejscowosc VALUES (322, 'Pisz');
INSERT INTO miejscowosc VALUES (323, 'Szczytno');
INSERT INTO miejscowosc VALUES (324, 'Węgorzewo');
INSERT INTO miejscowosc VALUES (325, 'Poznań');
INSERT INTO miejscowosc VALUES (326, 'Kalisz');
INSERT INTO miejscowosc VALUES (327, 'Konin');
INSERT INTO miejscowosc VALUES (328, 'Leszno');
INSERT INTO miejscowosc VALUES (329, 'Chodzież');
INSERT INTO miejscowosc VALUES (330, 'Czarnków');
INSERT INTO miejscowosc VALUES (331, 'Gniezno');
INSERT INTO miejscowosc VALUES (332, 'Gostyń');
INSERT INTO miejscowosc VALUES (333, 'Grodzisk Wielkopolski');
INSERT INTO miejscowosc VALUES (334, 'Jarocin');
INSERT INTO miejscowosc VALUES (335, 'Kalisz');
INSERT INTO miejscowosc VALUES (336, 'Kępno');
INSERT INTO miejscowosc VALUES (337, 'Koło');
INSERT INTO miejscowosc VALUES (338, 'Konin');
INSERT INTO miejscowosc VALUES (339, 'Kościan');
INSERT INTO miejscowosc VALUES (340, 'Krotoszyn');
INSERT INTO miejscowosc VALUES (341, 'Leszno');
INSERT INTO miejscowosc VALUES (342, 'Międzychód');
INSERT INTO miejscowosc VALUES (343, 'Nowy Tomyśl');
INSERT INTO miejscowosc VALUES (344, 'Oborniki');
INSERT INTO miejscowosc VALUES (345, 'Ostrów Wielkopolski');
INSERT INTO miejscowosc VALUES (346, 'Ostrzeszów');
INSERT INTO miejscowosc VALUES (347, 'Piła');
INSERT INTO miejscowosc VALUES (348, 'Pleszew');
INSERT INTO miejscowosc VALUES (349, 'Poznań');
INSERT INTO miejscowosc VALUES (350, 'Rawicz');
INSERT INTO miejscowosc VALUES (351, 'Słupca');
INSERT INTO miejscowosc VALUES (352, 'Szamotuły');
INSERT INTO miejscowosc VALUES (353, 'Środa Wielkopolska');
INSERT INTO miejscowosc VALUES (354, 'Śrem');
INSERT INTO miejscowosc VALUES (355, 'Turek');
INSERT INTO miejscowosc VALUES (356, 'Wągrowiec');
INSERT INTO miejscowosc VALUES (357, 'Wolsztyn');
INSERT INTO miejscowosc VALUES (358, 'Września');
INSERT INTO miejscowosc VALUES (359, 'Złotów');
INSERT INTO miejscowosc VALUES (360, 'Szczecin');
INSERT INTO miejscowosc VALUES (361, 'Koszalin');
INSERT INTO miejscowosc VALUES (362, 'Świnoujście');
INSERT INTO miejscowosc VALUES (363, 'Białogard');
INSERT INTO miejscowosc VALUES (364, 'Choszczno');
INSERT INTO miejscowosc VALUES (365, 'Drawsko Pomorskie');
INSERT INTO miejscowosc VALUES (366, 'Goleniów');
INSERT INTO miejscowosc VALUES (367, 'Gryfice');
INSERT INTO miejscowosc VALUES (368, 'Gryfino');
INSERT INTO miejscowosc VALUES (369, 'Kamień Pomorski');
INSERT INTO miejscowosc VALUES (370, 'Kołobrzeg');
INSERT INTO miejscowosc VALUES (371, 'Koszalin');
INSERT INTO miejscowosc VALUES (372, 'Łobez');
INSERT INTO miejscowosc VALUES (373, 'Myślibórz');
INSERT INTO miejscowosc VALUES (374, 'Police');
INSERT INTO miejscowosc VALUES (375, 'Pyrzyce');
INSERT INTO miejscowosc VALUES (376, 'Sławno');
INSERT INTO miejscowosc VALUES (377, 'Stargard');
INSERT INTO miejscowosc VALUES (378, 'Szczecinek');
INSERT INTO miejscowosc VALUES (379, 'Świdwin');
INSERT INTO miejscowosc VALUES (380, 'Wałcz');
INSERT INTO prawa_jazdy_kategorie VALUES (1, 'A1');
INSERT INTO prawa_jazdy_kategorie VALUES (2, 'A');
INSERT INTO prawa_jazdy_kategorie VALUES (3, 'B1');
INSERT INTO prawa_jazdy_kategorie VALUES (4, 'B');
INSERT INTO prawa_jazdy_kategorie VALUES (5, 'C1');
INSERT INTO prawa_jazdy_kategorie VALUES (6, 'C');
INSERT INTO prawa_jazdy_kategorie VALUES (7, 'D1');
INSERT INTO prawa_jazdy_kategorie VALUES (8, 'D');
INSERT INTO prawa_jazdy_kategorie VALUES (9, 'BE');
INSERT INTO prawa_jazdy_kategorie VALUES (10, 'C1E');
INSERT INTO prawa_jazdy_kategorie VALUES (11, 'CE');
INSERT INTO prawa_jazdy_kategorie VALUES (12, 'D1E');
INSERT INTO prawa_jazdy_kategorie VALUES (13, 'DE');
INSERT INTO prawa_jazdy_kategorie VALUES (14, 'T');
INSERT INTO mandaty_wystawiajacy VALUES (1, 'Olaf', 'Pawłowski');
INSERT INTO mandaty_wystawiajacy VALUES (2, 'Oskar', 'Grabowski');
INSERT INTO mandaty_wystawiajacy VALUES (3, 'Franciszek', 'Nowicki');
INSERT INTO mandaty_wystawiajacy VALUES (4, 'Marcelina', 'Błaszczyk');
INSERT INTO mandaty_wystawiajacy VALUES (5, 'Maja', 'Zielińska');
INSERT INTO mandaty_wystawiajacy VALUES (6, 'Klaudia', 'Wiśniewska');
INSERT INTO mandaty_wystawiajacy VALUES (7, 'Joanna', 'Krawczyk');
INSERT INTO mandaty_wystawiajacy VALUES (8, 'Kamil', 'Kwiatkowski');
INSERT INTO mandaty_wystawiajacy VALUES (9, 'Dominika', 'Górecka');
INSERT INTO mandaty_wystawiajacy VALUES (10, 'Anastazja', 'Borowska');
INSERT INTO mandaty_wystawiajacy VALUES (11, 'Dawid', 'Dudek');
INSERT INTO mandaty_wystawiajacy VALUES (12, 'Leon', 'Czerwiński');
INSERT INTO mandaty_wystawiajacy VALUES (13, 'Igor', 'Sikorski');
INSERT INTO mandaty_wystawiajacy VALUES (14, 'Klaudia', 'Baranowska');
INSERT INTO mandaty_wystawiajacy VALUES (15, 'Michalina', 'Szymczak');
INSERT INTO mandaty_wystawiajacy VALUES (16, 'Tymon', 'Zając');
INSERT INTO wykroczenia VALUES (1, 'Naruszenie zakazu zawracania na autostradzie lub drodze ekspresowej', 300.0, 5);
INSERT INTO wykroczenia VALUES (2, 'Kierowanie pojazdem przewożącym pasażerów niekorzystających z pasów bezpieczeństwa', 100.0, 4);
INSERT INTO wykroczenia VALUES (3, 'Wyprzedzanie bez zachowania bezpiecznego odstępu od wyprzedzanego pojazdu lub uczestnika ruchu', 300.0, 5);
INSERT INTO wykroczenia VALUES (4, 'Naruszenie obowiązku zatrzymania pojazdu w takim miejscu i na taki czas aby umożliwić pieszym swobodny dostęp do pojazdów komunikacji publicznej - w przypadku braku wysepki dla pasażerów na przystanku', 100.0, 0);
INSERT INTO wykroczenia VALUES (5, 'Holowanie pojazdu na połączeniu sztywnym, jeżeli nie jest sprawny co najmniej jeden układ hamulcowy, albo na połączeniu giętkim, jeżeli nie są sprawne dwa układy hamulcowe', 250.0, 0);
INSERT INTO wykroczenia VALUES (6, 'Naruszenie zakazu postoju w miejscach utrudniających dostęp do innego prawidłowo zaparkowanego pojazdu lub wyjazd tego pojazdu', 100.0, 1);
INSERT INTO wykroczenia VALUES (7, 'Zawracanie w warunkach, w których mogłoby to zagrażać bezpieczeństwu ruchu lub ruch ten utrudnić', 300.0, 5);
INSERT INTO wykroczenia VALUES (8, 'Nieużywanie wymaganego oświetlenia podczas zatrzymania lub postoju w warunkach niedostatecznej widoczności', 200.0, 3);
INSERT INTO wykroczenia VALUES (9, 'Wyprzedzanie na przejazdach dla rowerzystów lub bezpośrednio przed nimi', 200.0, 10);
INSERT INTO wykroczenia VALUES (10, 'Nieudzielenie pomocy ofiarom wypadku', 500.0, 10);
INSERT INTO wykroczenia VALUES (11, 'Holowanie więcej niż jednego pojazdu, z wyjątkiem pojazdu członowego', 250.0, 0);
INSERT INTO wykroczenia VALUES (12, 'Naruszenie zakazu postoju przed lub za przejazdem kolejowym na odcinku od przejazdu do słupka wskaźnikowego z jedną kreską', 100.0, 1);
INSERT INTO wykroczenia VALUES (13, 'Zatrzymywanie pojazdu w odległości mniejszej niż 15 m od punktów krańcowych wysepki, jeżeli jezdnia z prawej jej strony ma tylko jeden pas ruchu', 100.0, 1);
INSERT INTO wykroczenia VALUES (14, 'Naruszenie przez kierującego pojazdem innym niż silnikowy zakazu wyprzedzania innych pojazdów w czasie jazdy w warunkach zmniejszonej przejrzystości powietrza oraz obowiązku korzystania z pobocza drogi, a jeżeli nie jest to możliwe – to jazdy jak najbliżej krawędzi jezdni', 100.0, 2);
INSERT INTO wykroczenia VALUES (15, 'Omijanie pojazdu oczekującego na otwarcie ruchu przez przejazd kolejowy w sytuacji, w której wymagało to wjechania na część jezdni przeznaczoną dla przeciwnego kierunku ruchu', 250.0, 0);
INSERT INTO wykroczenia VALUES (16, 'Zatrzymywanie pojazdu na przejściu dla pieszych lub na przejeździe dla rowerzystów oraz w odległości mniejszej niż 10 m przed tym przejściem lub przejazdem, a na drodze dwukierunkowej o dwóch pasach ruchu – także za nimi', 200.0, 1);
INSERT INTO wykroczenia VALUES (17, 'Jazda wzdłuż po chodniku lub przejściu dla pieszych pojazdem silnikowym', 250.0, 0);
INSERT INTO wykroczenia VALUES (18, 'Naruszenie zakazu objeżdżania opuszczonych zapór lub półzapór oraz wjeżdżania na przejazd, jeśli opuszczanie ich zostało rozpoczęte lub podnoszenie ich nie zostało zakończone', 300.0, 4);
INSERT INTO wykroczenia VALUES (19, 'Naruszenie zakazu postoju w miejscach utrudniających wjazd lub wyjazd', 100.0, 1);
INSERT INTO wykroczenia VALUES (20, 'Zatrzymywanie pojazdu na pasie między jezdniami', 100.0, 1);
INSERT INTO wykroczenia VALUES (21, 'Zatrzymywanie pojazdu w odległości mniejszej niż 10 m od przedniej strony znaku lub sygnału drogowego, jeżeli pojazd je zasłania', 100.0, 1);
INSERT INTO wykroczenia VALUES (22, 'Nieodpowiednie ustawienie pojazdu na jezdni przed skręceniem', 150.0, 0);
INSERT INTO wykroczenia VALUES (23, 'Naruszenie warunków dopuszczalności zatrzymania lub postoju pojazdu na chodniku', 100.0, 1);
INSERT INTO wykroczenia VALUES (24, 'Naruszenie przez kierującego warunków holowania - brak oznaczenia lub niewłaściwe oznaczenie pojazdu holowanego', 150.0, 0);
INSERT INTO wykroczenia VALUES (25, 'Hamowanie w sposób powodujący zagrożenie bezpieczeństwa ruchu lub jego utrudnienie', 200.0, 0);
INSERT INTO wykroczenia VALUES (26, 'Nadużywanie sygnałów dźwiękowych lub świetlnych', 100.0, 0);
INSERT INTO wykroczenia VALUES (27, 'Brak sygnalizowania lub niewłaściwe sygnalizowanie postoju pojazdu z powodu uszkodzenia lub wypadku', 150.0, 1);
INSERT INTO wykroczenia VALUES (28, 'Naruszenie zakazu wjeżdżania na przejazd jeśli po jego drugiej stronie nie ma miejsca do kontynuowania jazdy', 300.0, 4);
INSERT INTO wykroczenia VALUES (29, 'Kierowanie bez uprawnienia rowerem, wózkiem rowerowym lub pojazdem zaprzęgowym', 100.0, 0);
INSERT INTO wykroczenia VALUES (30, 'Naruszenie zakazów cofania w tunelach, na mostach i wiaduktach', 200.0, 2);
INSERT INTO wykroczenia VALUES (31, 'Jazda z prędkością utrudniającą ruch innym kierującym', 100.0, 2);
INSERT INTO wykroczenia VALUES (32, 'Nieustąpienie przez kierującego pojazdem pierwszeństwa rowerowi przy przejeżdżaniu przez drogę dla rowerów poza jezdnią', 350.0, 6);
INSERT INTO egzaminatorzy VALUES (1, 'Michalina', 'Marciniak', '052167');
INSERT INTO egzaminatorzy VALUES (2, 'Julian', 'Kaczmarek', '959962');
INSERT INTO egzaminatorzy VALUES (3, 'Kajetan', 'Andrzejewski', '190216');
INSERT INTO egzaminatorzy VALUES (4, 'łucja', 'Cieślak', '456089');
INSERT INTO egzaminatorzy VALUES (5, 'Adam', 'Konieczny', '002351');
INSERT INTO egzaminatorzy VALUES (6, 'Helena', 'Czerwińska', '355278');
INSERT INTO egzaminatorzy VALUES (7, 'Filip', 'Sobczak', '919923');
INSERT INTO egzaminatorzy VALUES (8, 'Nikodem', 'Szulc', '497153');
INSERT INTO egzaminatorzy VALUES (9, 'Blanka', 'Zając', '028189');
INSERT INTO egzaminatorzy VALUES (10, 'Liliana', 'Kwiatkowska', '221676');
INSERT INTO egzaminatorzy VALUES (11, 'Antonina', 'Olszewska', '831831');
INSERT INTO egzaminatorzy VALUES (12, 'Bartłomiej', 'Pawłowski', '062964');
INSERT INTO egzaminatorzy VALUES (13, 'Patrycja', 'Woźniak', '053114');
INSERT INTO egzaminatorzy VALUES (14, 'Sebastian', 'Witkowski', '556752');
INSERT INTO egzaminatorzy VALUES (15, 'Nadia', 'Malinowska', '782848');
INSERT INTO egzaminatorzy VALUES (16, 'Bartłomiej', 'Makowski', '339723');
INSERT INTO egzaminatorzy VALUES (17, 'Joanna', 'Kowalczyk', '292041');
INSERT INTO egzaminatorzy VALUES (18, 'Martyna', 'Sobczak', '246969');
INSERT INTO egzaminatorzy VALUES (19, 'Maja', 'Kalinowska', '674690');
INSERT INTO egzaminatorzy VALUES (20, 'Pola', 'Czerwińska', '610647');
INSERT INTO egzaminatorzy VALUES (21, 'Marta', 'Kaźmierczak', '354494');
INSERT INTO egzaminatorzy VALUES (22, 'Liliana', 'Olszewska', '090500');
INSERT INTO egzaminatorzy VALUES (23, 'Wojciech', 'Zakrzewski', '287789');
INSERT INTO egzaminatorzy VALUES (24, 'Szymon', 'Kubiak', '907164');
INSERT INTO egzaminatorzy VALUES (25, 'Weronika', 'Kamińska', '011481');
INSERT INTO egzaminatorzy VALUES (26, 'Alicja', 'Jankowska', '518703');
INSERT INTO egzaminatorzy VALUES (27, 'Hanna', 'Baranowska', '603385');
INSERT INTO egzaminatorzy VALUES (28, 'Dominika', 'Włodarczyk', '221528');
INSERT INTO egzaminatorzy VALUES (29, 'Julian', 'Głowacki', '080229');
INSERT INTO egzaminatorzy VALUES (30, 'Magdalena', 'Wróblewska', '342074');
INSERT INTO egzaminatorzy VALUES (31, 'Tomasz', 'Kaczmarek', '648669');
INSERT INTO egzaminatorzy VALUES (32, 'Maciej', 'Jankowski', '899748');
INSERT INTO firma VALUES (892272, '6321981559', '241404080', '', 'Huber Polska Spółka z o.o. Usługi Transportowe', '', '327452208', 'Grunwaldzka', '264', '43-603', 262);
INSERT INTO firma VALUES (923828, '6562303631', '260357456', '0000347139', 'Elmar Transport Spółka z o.o. Spółka Komandytowa', 'elmar@elmar.com.pl', '413861487', 'Dygasińskiego', '126', '28-300', 292);
INSERT INTO firma VALUES (334791, '9442117910', '120047721', '0000237761', 'Trans Kar Spółka z o.o.', '', '122565830', 'Piłsudskiego', '23', '32-050', 124);
INSERT INTO firma VALUES (431250, '7742862232', '140163854', '0000239493', 'Budmat Transport Spółka z o.o.', '', '242680253', 'Otolińska', '25', '09-407', 161);
INSERT INTO firma VALUES (421568, '1251335632', '015655749', '0000159974', 'El Trans Spółka z o.o.', 'biuro@el-trans.com', '227867061', 'Weteranów', '100', '05-250', 175);
INSERT INTO firma VALUES (974633, '6972096367', '411499582', '0000126704', 'Trans Truck Sp. Komandytowo-Akcyjna Dawid Kalinowski', '', '672146251', 'Energetyków', '3', '64-100', 341);
INSERT INTO firma VALUES (550994, '9521914279', '015432972', '0000155014', 'Euro Trans Spółka z o.o. P.H.U.', 'recepcja@eurotrans.waw.pl', '228522592', 'Taśmowa', '3', '02-677', 138);
INSERT INTO firma VALUES (656369, '8170008329', '690254186', '0000002372', 'Waldrom Spółka Jawna Usługi Transportowe Roman Rzeszutek Waldemar Groele', 'waldrom@waldrom.pl', '175843575', 'Krakowska', '273', '39-300', 207);
INSERT INTO firma VALUES (240750, '7120154376', '430067600', '0000204663', 'Arb Trans Spółka z o.o.', '', '817429118', 'Świętokrzyska', '5/.12', '20-867', 66);
INSERT INTO firma VALUES (518419, '8211698303', '710457810', '0000010619', 'Zakład Transportu Grupa Kapitałowa Polimex Spółka z o.o.', '', '256439703', 'Terespolska', '12', '08-110', 168);
INSERT INTO firma VALUES (974775, '7792346900', '300973510', '', 'Zarząd Transportu Miejskiego', 'ztm@ztm.poznan.pl', '618346146', 'Matejki', '59', '60-766', 349);
INSERT INTO firma VALUES (623470, '7530012813', '530789508', '', 'Franciszek Raczyński Transport Towarowy', 'ttraczynski@interia.pl', '774354276', 'Rynek', '41 l. 2', '48-385', 187);
INSERT INTO firma VALUES (1014868, '7631002503', '570177837', '', 'Al-Trans P.H.U. Mariusz Szarek', 'info@altrans.com.pl', '672165789', 'Grunwaldzka', '13', '64-980', 330);
INSERT INTO firma VALUES (118152, '8792595058', '871229099', '', 'Daw-Trans F.H.U. Dawid Kujawski', '', '566742146', 'Kopernika', '114B', '87-122', 49);
INSERT INTO firma VALUES (195419, '7680007280', '590310309', '', 'Bud-Trans P.P.H.U.', 'budtrans@alpha.net.pl', '447553946', 'Rolna', '6', '26-300', 102);
INSERT INTO firma VALUES (873093, '6260011110', '271692864', '0000095976', 'Eko-Trans Spółka Jawna P.H.U. Henryk Orłowski Grażyna Orłowska', 'eko_trans@interia.pl', '322737057', 'Wolności', '21', '42-672', 286);
INSERT INTO firma VALUES (581225, '9511644111', '012341134', '0000181577', 'Go-Trans Gmbh Spółka z o.o.', 'gotrans@gotrans.pl', '226487600', 'Kazury', '2 l. 28', '02-795', 138);
INSERT INTO firma VALUES (655919, '8721066430', '850393487', '', 'Iglotrans P.P.H.U. Krzysztof Zima', '', '146779117', 'Rzeszowska', '194a', '39-204', 198);
INSERT INTO firma VALUES (1113535, '9550002345', '810582162', '', 'RT trans Tadeusz Rybiński', 'rttrans@rt-trans.pl', '914647327', 'Borsucza', '6', '70-887', 360);
INSERT INTO osrodki VALUES (1, 'Wojewódzki Ośrodek Ruchu Drogowego w Elblągu', 'ul. Skrzydlata', '1', '82-300', 309);
INSERT INTO osrodki VALUES (2, 'Wojewódzki Ośrodek Ruchu Drogowego w Tarnobrzegu', 'ul. Sikorskiego', '86A', '39-400', 216);
INSERT INTO osrodki VALUES (3, 'Wojewódzki Ośrodek Ruchu Drogowego w Ostrołęce', 'ul. Rolna', '30', '07-410', 157);
INSERT INTO osrodki VALUES (4, 'Wojewódzki Ośrodek Ruchu Drogowego w Zielonej Górze', 'ul. Nowa', '4b', '65-339', 89);
INSERT INTO osrodki VALUES (5, 'Małopolski Ośrodek Ruchu Drogowego w Tarnowie', 'ul. Okrężna', '2F', '33-104', 134);
INSERT INTO osrodki VALUES (6, 'Wojewódzki Ośrodek Ruchu Drogowego w Toruniu', 'ul. Polna', '109/111', '87-100', 49);
INSERT INTO osrodki VALUES (7, 'Wojewódzki Ośrodek Ruchu Drogowego w Szczecinie', 'ul. Maksymiliana Golisza', '10B', '71-682', 360);
INSERT INTO osrodki VALUES (8, 'Wojewódzki Ośrodek Ruchu Drogowego w Słupsku', 'ul. Mierosławskiego', '10', '76-200', 249);
INSERT INTO osrodki VALUES (9, 'Wojewódzki Ośrodek Ruchu Drogowego we Wrocławiu', 'ul. Łagiewnicka', '12', '50-512', 27);
INSERT INTO osrodki VALUES (10, 'Wojewódzki Ośrodek Ruchu Drogowego w Białej Podlaskiej', 'ul. Orzechowa', '60', '21-500', 58);
INSERT INTO osrodki VALUES (11, 'Wojewódzki Ośrodek Ruchu Drogowego w Jeleniej Górze', 'ul. Rataja', '9', '58-560', 10);
INSERT INTO osrodki VALUES (12, 'Wojewódzki Ośrodek Ruchu Drogowego w Piotrkowie Trybunalskim', 'ul. Gliniana', '17', '97-300', 105);
INSERT INTO osrodki VALUES (13, 'Małopolski Ośrodek Ruchu Drogowego w Krakowie', 'ul. Nowohucka', '33a', '30-728', 124);
INSERT INTO osrodki VALUES (14, 'Wojewódzki Ośrodek Ruchu Drogowego - Regionalne Centrum Bezpieczeństwa Ruchu Drogowego w Olsztynie', 'ul. Towarowa', '17', '10-416', 320);
INSERT INTO osrodki VALUES (15, 'Wojewódzki Ośrodek Ruchu Drogowego w Zamościu', 'ul. Droga Męczenników Rotundy', '2', '22-400', 77);
INSERT INTO osrodki VALUES (16, 'Zachodniopomorski Ośrodek Ruchu Drogowego w Koszalinie', 'ul. Mieszka I', '39', '75-124', 371);
INSERT INTO sposob_zasilania VALUES (1, '﻿P - Benzyna');
INSERT INTO sposob_zasilania VALUES (2, 'D - Diesel');
INSERT INTO sposob_zasilania VALUES (3, 'LPG - gaz LPG');
INSERT INTO sposob_zasilania VALUES (4, 'EE - pojazd napędzany elektrycznie');
INSERT INTO sposob_zasilania VALUES (5, 'CNG - gaz ziemny');
INSERT INTO marka VALUES (1, 'acura');
INSERT INTO marka VALUES (2, 'aixam');
INSERT INTO marka VALUES (3, 'alfa-romeo');
INSERT INTO marka VALUES (4, 'aro');
INSERT INTO marka VALUES (5, 'asia');
INSERT INTO marka VALUES (6, 'aston-martin');
INSERT INTO marka VALUES (7, 'audi');
INSERT INTO marka VALUES (8, 'austin');
INSERT INTO marka VALUES (9, 'autobianchi');
INSERT INTO marka VALUES (10, 'bentley');
INSERT INTO marka VALUES (11, 'bmw');
INSERT INTO marka VALUES (12, 'bugatti');
INSERT INTO marka VALUES (13, 'cadillac');
INSERT INTO marka VALUES (14, 'caterham');
INSERT INTO marka VALUES (15, 'chevrolet');
INSERT INTO marka VALUES (16, 'chrysler');
INSERT INTO marka VALUES (17, 'citroen');
INSERT INTO marka VALUES (18, 'comarth');
INSERT INTO marka VALUES (19, 'dacia');
INSERT INTO marka VALUES (20, 'daewoo');
INSERT INTO marka VALUES (21, 'daihatsu');
INSERT INTO marka VALUES (22, 'de-lorean');
INSERT INTO marka VALUES (23, 'dodge');
INSERT INTO marka VALUES (24, 'ferrari');
INSERT INTO marka VALUES (25, 'fiat');
INSERT INTO marka VALUES (26, 'ford');
INSERT INTO marka VALUES (27, 'galloper');
INSERT INTO marka VALUES (28, 'gaz');
INSERT INTO marka VALUES (29, 'honda');
INSERT INTO marka VALUES (30, 'hummer');
INSERT INTO marka VALUES (31, 'hyundai');
INSERT INTO marka VALUES (32, 'infiniti');
INSERT INTO marka VALUES (33, 'isuzu');
INSERT INTO marka VALUES (34, 'jaguar');
INSERT INTO marka VALUES (35, 'jeep');
INSERT INTO marka VALUES (36, 'kaipan');
INSERT INTO marka VALUES (37, 'kia');
INSERT INTO marka VALUES (38, 'lada');
INSERT INTO marka VALUES (39, 'lamborghini');
INSERT INTO marka VALUES (40, 'lancia');
INSERT INTO marka VALUES (41, 'land-rover');
INSERT INTO marka VALUES (42, 'lexus');
INSERT INTO marka VALUES (43, 'ligier');
INSERT INTO marka VALUES (44, 'lincoln');
INSERT INTO marka VALUES (45, 'lotus');
INSERT INTO marka VALUES (46, 'maserati');
INSERT INTO marka VALUES (47, 'maybach');
INSERT INTO marka VALUES (48, 'mazda');
INSERT INTO marka VALUES (49, 'mclaren');
INSERT INTO marka VALUES (50, 'mercedes-benz');
INSERT INTO marka VALUES (51, 'mercury');
INSERT INTO marka VALUES (52, 'mg');
INSERT INTO marka VALUES (53, 'microcar');
INSERT INTO marka VALUES (54, 'mini');
INSERT INTO marka VALUES (55, 'mitsubishi');
INSERT INTO marka VALUES (56, 'morgan');
INSERT INTO marka VALUES (57, 'nissan');
INSERT INTO marka VALUES (58, 'nsu');
INSERT INTO marka VALUES (59, 'nysa');
INSERT INTO marka VALUES (60, 'opel');
INSERT INTO marka VALUES (61, 'peugeot');
INSERT INTO marka VALUES (62, 'piaggio');
INSERT INTO marka VALUES (63, 'plymouth');
INSERT INTO marka VALUES (64, 'polonez');
INSERT INTO marka VALUES (65, 'pontiac');
INSERT INTO marka VALUES (66, 'porsche');
INSERT INTO marka VALUES (67, 'proton');
INSERT INTO marka VALUES (68, 'rayton-fissore');
INSERT INTO marka VALUES (69, 'renault');
INSERT INTO marka VALUES (70, 'rolls-royce');
INSERT INTO marka VALUES (71, 'rover');
INSERT INTO marka VALUES (72, 'saab');
INSERT INTO marka VALUES (73, 'seat');
INSERT INTO marka VALUES (74, 'shuanghuan');
INSERT INTO marka VALUES (75, 'skoda');
INSERT INTO marka VALUES (76, 'smart');
INSERT INTO marka VALUES (77, 'ssangyong');
INSERT INTO marka VALUES (78, 'subaru');
INSERT INTO marka VALUES (79, 'suzuki');
INSERT INTO marka VALUES (80, 'syrena');
INSERT INTO marka VALUES (81, 'tesla');
INSERT INTO marka VALUES (82, 'toyota');
INSERT INTO marka VALUES (83, 'trabant');
INSERT INTO marka VALUES (84, 'triumph');
INSERT INTO marka VALUES (85, 'tvr');
INSERT INTO marka VALUES (86, 'uaz');
INSERT INTO marka VALUES (87, 'vauxhall');
INSERT INTO marka VALUES (88, 'volkswagen');
INSERT INTO marka VALUES (89, 'volvo');
INSERT INTO marka VALUES (90, 'warszawa');
INSERT INTO marka VALUES (91, 'wartburg');
INSERT INTO model VALUES (1, 57, '300-zx', 1, 5, 'po prawej');
INSERT INTO model VALUES (2, 60, 'agila', 1, 3, 'po prawej');
INSERT INTO model VALUES (3, 69, '10', 1, 4, 'po prawej');
INSERT INTO model VALUES (4, 48, 'rx-7', 1, 3, 'po prawej');
INSERT INTO model VALUES (5, 24, '599gtb', 2, 4, 'po prawej');
INSERT INTO model VALUES (6, 80, '101', 3, 2, 'po prawej');
INSERT INTO model VALUES (7, 15, 'trans-sport', 3, 2, 'po prawej');
INSERT INTO model VALUES (8, 21, 'yrv', 3, 2, 'po prawej');
INSERT INTO model VALUES (9, 15, 'c-30', 2, 3, 'po prawej');
INSERT INTO model VALUES (10, 34, 'mk-ii', 1, 8, 'po prawej');
INSERT INTO model VALUES (11, 19, 'pick-up', 4, 5, 'po prawej');
INSERT INTO model VALUES (12, 6, 'v8', 3, 2, 'po prawej');
INSERT INTO model VALUES (13, 25, '850', 2, 3, 'po prawej');
INSERT INTO model VALUES (14, 60, 'monza', 1, 2, 'po prawej');
INSERT INTO model VALUES (15, 30, 'h2', 1, 6, 'po prawej');
INSERT INTO model VALUES (16, 19, 'solenza', 1, 6, 'po prawej');
INSERT INTO model VALUES (17, 17, 'c5', 4, 8, 'po prawej');
INSERT INTO model VALUES (18, 15, 'rezzo', 2, 5, 'po prawej');
INSERT INTO model VALUES (19, 57, 'gt-r', 1, 4, 'po prawej');
INSERT INTO model VALUES (20, 14, 'academy', 2, 6, 'po prawej');
INSERT INTO model VALUES (21, 23, 'caravan', 2, 4, 'po prawej');
INSERT INTO model VALUES (22, 26, 'sierra', 1, 8, 'po prawej');
INSERT INTO model VALUES (23, 79, 'super-carry', 1, 4, 'po prawej');
INSERT INTO model VALUES (24, 71, 'city-rover', 1, 8, 'po prawej');
INSERT INTO model VALUES (25, 60, 'speedster', 1, 8, 'po prawej');
INSERT INTO model VALUES (26, 24, 'f50', 1, 6, 'po prawej');
INSERT INTO model VALUES (27, 88, 'santana', 2, 6, 'po prawej');
INSERT INTO model VALUES (28, 16, 'gs', 1, 8, 'po prawej');
INSERT INTO model VALUES (29, 11, 'seria-3', 2, 8, 'po prawej');
INSERT INTO model VALUES (30, 78, 'levork', 1, 2, 'po prawej');
INSERT INTO model VALUES (31, 25, '131', 1, 8, 'po prawej');
INSERT INTO model VALUES (32, 88, 'crafter', 2, 7, 'po prawej');
INSERT INTO model VALUES (33, 10, 'turbo-r', 4, 5, 'po prawej');
INSERT INTO model VALUES (34, 50, 'w124-1984-1993', 2, 3, 'po prawej');
INSERT INTO model VALUES (35, 11, 'z3', 1, 6, 'po prawej');
INSERT INTO model VALUES (36, 2, 'roadline', 1, 3, 'po prawej');
INSERT INTO model VALUES (37, 42, 'ls', 2, 2, 'po prawej');
INSERT INTO model VALUES (38, 38, '2170', 3, 5, 'po prawej');
INSERT INTO model VALUES (39, 3, 'giulia', 2, 2, 'po prawej');
INSERT INTO model VALUES (40, 41, 'discovery', 1, 3, 'po prawej');
INSERT INTO model VALUES (41, 25, 'palio', 2, 7, 'po prawej');
INSERT INTO model VALUES (42, 23, 'stratus', 2, 3, 'po prawej');
INSERT INTO model VALUES (43, 57, 'almera', 2, 3, 'po prawej');
INSERT INTO model VALUES (44, 60, 'nova', 2, 6, 'po prawej');
INSERT INTO model VALUES (45, 44, 'mkz', 1, 7, 'po prawej');
INSERT INTO model VALUES (46, 73, 'exeo', 2, 4, 'po prawej');
INSERT INTO model VALUES (47, 50, 'slk', 1, 2, 'po prawej');
INSERT INTO model VALUES (48, 38, '2112', 4, 2, 'po prawej');
INSERT INTO model VALUES (49, 77, 'korrando', 3, 8, 'po prawej');
INSERT INTO model VALUES (50, 53, 'm-go', 2, 4, 'po prawej');
INSERT INTO model VALUES (51, 5, 'rocsta', 1, 4, 'po prawej');
INSERT INTO model VALUES (52, 89, 'c30', 4, 2, 'po prawej');
INSERT INTO model VALUES (53, 34, 's-type', 2, 6, 'po prawej');
INSERT INTO model VALUES (54, 73, 'mii', 3, 6, 'po prawej');
INSERT INTO model VALUES (55, 69, 'grand-espace', 3, 5, 'po prawej');
INSERT INTO model VALUES (56, 43, 'altul', 1, 5, 'po prawej');
INSERT INTO model VALUES (57, 15, 'suburban', 1, 8, 'po prawej');
INSERT INTO model VALUES (58, 82, 'supra', 1, 6, 'po prawej');
INSERT INTO model VALUES (59, 38, '2107', 1, 2, 'po prawej');
INSERT INTO model VALUES (60, 52, 'f', 1, 3, 'po prawej');
INSERT INTO model VALUES (61, 66, '356', 3, 8, 'po prawej');
INSERT INTO model VALUES (62, 85, 'tamora', 1, 2, 'po prawej');
INSERT INTO model VALUES (63, 82, 'yaris-verso', 1, 8, 'po prawej');
INSERT INTO model VALUES (64, 15, 'equinox', 1, 2, 'po prawej');
INSERT INTO model VALUES (65, 55, 'endeavor', 2, 3, 'po prawej');
INSERT INTO model VALUES (66, 50, 'vaneo', 1, 3, 'po prawej');
INSERT INTO model VALUES (67, 51, 'mariner', 1, 3, 'po prawej');
INSERT INTO model VALUES (68, 75, 'praktik', 2, 8, 'po prawej');
INSERT INTO model VALUES (69, 7, 's2', 4, 3, 'po prawej');
INSERT INTO model VALUES (70, 23, 'viper', 2, 4, 'po prawej');
INSERT INTO model VALUES (71, 15, 's-10', 2, 2, 'po prawej');
INSERT INTO model VALUES (72, 50, '230', 2, 5, 'po prawej');
INSERT INTO model VALUES (73, 31, 'h-1-starex', 1, 3, 'po prawej');
INSERT INTO model VALUES (74, 77, 'family', 3, 8, 'po prawej');
INSERT INTO model VALUES (75, 88, 'bora', 2, 7, 'po prawej');
INSERT INTO model VALUES (76, 40, 'kappa', 2, 5, 'po prawej');
INSERT INTO model VALUES (77, 31, 'azera', 4, 7, 'po prawej');
INSERT INTO model VALUES (78, 26, 'courier', 2, 4, 'po prawej');
INSERT INTO model VALUES (79, 82, 'aygo', 2, 5, 'po prawej');
INSERT INTO model VALUES (80, 60, 'tigra', 1, 5, 'po prawej');
INSERT INTO model VALUES (81, 80, '103', 1, 7, 'po prawej');
INSERT INTO model VALUES (82, 7, 'rs2', 2, 8, 'po prawej');
INSERT INTO model VALUES (83, 29, 'cr-v', 1, 5, 'po prawej');
INSERT INTO model VALUES (84, 63, 'gran-fury', 1, 2, 'po prawej');
INSERT INTO model VALUES (85, 37, 'spectra', 1, 2, 'po prawej');
INSERT INTO model VALUES (86, 15, 'trailblazer', 1, 8, 'po prawej');
INSERT INTO model VALUES (87, 29, 'civic', 2, 4, 'po prawej');
INSERT INTO model VALUES (88, 38, '2109', 3, 4, 'po prawej');
INSERT INTO model VALUES (89, 32, 'fx', 1, 4, 'po prawej');
INSERT INTO model VALUES (90, 69, '25', 3, 8, 'po prawej');
INSERT INTO model VALUES (91, 85, 'cerbera', 1, 2, 'po prawej');
INSERT INTO model VALUES (92, 48, '121', 3, 4, 'po prawej');
INSERT INTO model VALUES (93, 72, '900', 3, 3, 'po prawej');
INSERT INTO model VALUES (94, 65, 'g6', 4, 2, 'po prawej');
INSERT INTO model VALUES (95, 57, 'pulsar', 3, 3, 'po prawej');
INSERT INTO model VALUES (96, 15, 'caprice', 2, 5, 'po prawej');
INSERT INTO model VALUES (97, 57, 'note', 1, 8, 'po prawej');
INSERT INTO model VALUES (98, 66, 'panamera', 2, 3, 'po prawej');
INSERT INTO model VALUES (99, 61, '108', 2, 6, 'po prawej');
INSERT INTO model VALUES (100, 55, 'l400', 1, 7, 'po prawej');
INSERT INTO model VALUES (101, 57, '240-sx', 1, 8, 'po prawej');
INSERT INTO model VALUES (102, 25, 'marea', 2, 5, 'po prawej');
INSERT INTO model VALUES (103, 40, 'musa', 2, 5, 'po prawej');
INSERT INTO model VALUES (104, 40, 'thesis', 2, 5, 'po prawej');
INSERT INTO model VALUES (105, 82, 'land-cruiser', 4, 2, 'po prawej');
INSERT INTO model VALUES (106, 63, 'valiant', 2, 3, 'po prawej');
INSERT INTO model VALUES (107, 61, '505', 3, 2, 'po prawej');
INSERT INTO model VALUES (108, 88, 'new-beetle', 1, 6, 'po prawej');
INSERT INTO model VALUES (109, 72, '90', 1, 4, 'po prawej');
INSERT INTO model VALUES (110, 60, 'kadett', 2, 5, 'po prawej');
INSERT INTO model VALUES (111, 26, 'fairlane', 4, 6, 'po prawej');
INSERT INTO model VALUES (112, 38, 'aleko', 2, 4, 'po prawej');
INSERT INTO model VALUES (113, 15, 'monte-carlo', 4, 7, 'po prawej');
INSERT INTO model VALUES (114, 7, 'rs4', 1, 7, 'po prawej');
INSERT INTO model VALUES (115, 29, 'nsx', 3, 8, 'po prawej');
INSERT INTO model VALUES (116, 23, 'charger', 2, 2, 'po prawej');
INSERT INTO model VALUES (117, 63, 'turismo', 4, 5, 'po prawej');
INSERT INTO model VALUES (118, 37, 'mentor', 1, 2, 'po prawej');
INSERT INTO model VALUES (119, 3, '4c', 2, 6, 'po prawej');
INSERT INTO model VALUES (120, 75, 'fabia', 2, 8, 'po prawej');
INSERT INTO model VALUES (121, 48, '2', 2, 3, 'po prawej');
INSERT INTO model VALUES (122, 69, 'espace', 2, 6, 'po prawej');
INSERT INTO model VALUES (123, 29, 'shuttle', 2, 2, 'po prawej');
INSERT INTO model VALUES (124, 71, 'sd', 1, 8, 'po prawej');
INSERT INTO model VALUES (125, 13, 'allante', 1, 5, 'po prawej');
INSERT INTO model VALUES (126, 26, 'freestyle', 3, 7, 'po prawej');
INSERT INTO model VALUES (127, 6, 'db6', 1, 8, 'po prawej');
INSERT INTO model VALUES (128, 23, 'journey', 4, 8, 'po prawej');
INSERT INTO model VALUES (129, 4, 'seria-320', 4, 5, 'po prawej');
INSERT INTO model VALUES (130, 17, 'c2', 1, 6, 'po prawej');
INSERT INTO model VALUES (131, 43, 'optima', 2, 2, 'po prawej');
INSERT INTO model VALUES (132, 55, 'starion', 4, 5, 'po prawej');
INSERT INTO model VALUES (133, 29, 'city', 1, 7, 'po prawej');
INSERT INTO model VALUES (134, 89, 'v90', 1, 3, 'po prawej');
INSERT INTO model VALUES (135, 25, 'linea', 2, 3, 'po prawej');
INSERT INTO model VALUES (136, 17, 'zx', 2, 2, 'po prawej');
INSERT INTO model VALUES (137, 1, 'integra', 1, 6, 'po prawej');
INSERT INTO model VALUES (138, 35, 'wrangler', 3, 7, 'po prawej');
INSERT INTO model VALUES (139, 88, 'eos', 2, 4, 'po prawej');
INSERT INTO model VALUES (140, 78, '1800-coupe', 2, 2, 'po prawej');
INSERT INTO model VALUES (141, 46, 'ghibli', 2, 7, 'po prawej');
INSERT INTO model VALUES (142, 37, 'magentis', 2, 5, 'po prawej');
INSERT INTO model VALUES (143, 31, 'i25', 1, 7, 'po prawej');
INSERT INTO model VALUES (144, 88, 'amarok', 4, 7, 'po prawej');
INSERT INTO model VALUES (145, 42, 'es', 4, 8, 'po prawej');
INSERT INTO model VALUES (146, 88, 'sharan', 2, 8, 'po prawej');
INSERT INTO model VALUES (147, 71, '800', 3, 8, 'po prawej');
INSERT INTO model VALUES (148, 3, 'sprint', 3, 3, 'po prawej');
INSERT INTO model VALUES (149, 55, 'pajero', 3, 4, 'po prawej');
INSERT INTO model VALUES (150, 7, '100', 1, 4, 'po prawej');
INSERT INTO model VALUES (151, 15, 'venture', 3, 3, 'po prawej');
INSERT INTO model VALUES (152, 17, 'c4-cactus', 4, 2, 'po prawej');
INSERT INTO model VALUES (153, 29, 'logo', 1, 2, 'po prawej');
INSERT INTO model VALUES (154, 15, 'corsica', 1, 7, 'po prawej');
INSERT INTO model VALUES (155, 69, 'alpine-a310', 1, 5, 'po prawej');
INSERT INTO model VALUES (156, 11, '1m', 1, 7, 'po prawej');
INSERT INTO model VALUES (157, 79, 'sx4', 1, 4, 'po prawej');
INSERT INTO model VALUES (158, 55, 'eclipse', 2, 8, 'po prawej');
INSERT INTO model VALUES (159, 13, 'cimarron', 2, 3, 'po prawej');
INSERT INTO model VALUES (160, 51, 'marquis', 3, 2, 'po prawej');
INSERT INTO model VALUES (161, 89, 'v70', 4, 6, 'po prawej');
INSERT INTO model VALUES (162, 48, 'tribute', 1, 6, 'po prawej');
INSERT INTO model VALUES (163, 23, 'omni', 3, 3, 'po prawej');
INSERT INTO model VALUES (164, 6, 'bulldog', 1, 2, 'po prawej');
INSERT INTO model VALUES (165, 39, 'gallardo', 1, 5, 'po prawej');
INSERT INTO model VALUES (166, 2, 'scouty', 1, 5, 'po prawej');
INSERT INTO model VALUES (167, 82, 'dyna', 2, 8, 'po prawej');
INSERT INTO model VALUES (168, 57, 'bluebird', 4, 2, 'po prawej');
INSERT INTO model VALUES (169, 15, 'citation', 1, 5, 'po prawej');
INSERT INTO model VALUES (170, 24, 'dino-gt4', 1, 2, 'po prawej');
INSERT INTO model VALUES (171, 11, 'x6', 2, 8, 'po prawej');
INSERT INTO model VALUES (172, 44, 'mark-lt', 1, 6, 'po prawej');
INSERT INTO model VALUES (173, 26, 'expedition', 2, 7, 'po prawej');
INSERT INTO model VALUES (174, 51, 'mountaineer', 2, 8, 'po prawej');
INSERT INTO model VALUES (175, 23, 'caliber', 2, 7, 'po prawej');
INSERT INTO model VALUES (176, 44, 'mkx', 1, 3, 'po prawej');
INSERT INTO model VALUES (177, 88, 'phaeton', 1, 6, 'po prawej');
INSERT INTO model VALUES (178, 63, 'caravelle', 1, 5, 'po prawej');
INSERT INTO model VALUES (179, 65, 'le-mans', 1, 8, 'po prawej');
INSERT INTO model VALUES (180, 19, '1300', 2, 8, 'po prawej');
INSERT INTO model VALUES (181, 60, 'calibra', 2, 4, 'po prawej');
INSERT INTO model VALUES (182, 10, 'turbo-rt', 2, 6, 'po prawej');
INSERT INTO model VALUES (183, 57, '350-z', 2, 3, 'po prawej');
INSERT INTO model VALUES (184, 39, 'murcielago', 4, 7, 'po prawej');
INSERT INTO model VALUES (185, 19, 'sandero-stepway', 1, 5, 'po prawej');
INSERT INTO model VALUES (186, 11, 'x5-m', 4, 7, 'po prawej');
INSERT INTO model VALUES (187, 48, '626', 1, 4, 'po prawej');
INSERT INTO model VALUES (188, 17, 'gsa', 1, 3, 'po prawej');
INSERT INTO model VALUES (189, 6, 'db7', 1, 6, 'po prawej');
INSERT INTO model VALUES (190, 41, 'freelander', 3, 2, 'po prawej');
INSERT INTO model VALUES (191, 39, 'huracan', 1, 7, 'po prawej');
INSERT INTO model VALUES (192, 60, 'movano', 2, 4, 'po prawej');
INSERT INTO model VALUES (193, 82, 'hiace', 2, 5, 'po prawej');
INSERT INTO model VALUES (194, 25, 'punto-2012', 2, 7, 'po prawej');
INSERT INTO model VALUES (195, 82, 'iq', 1, 5, 'po prawej');
INSERT INTO model VALUES (196, 46, 'gransport', 2, 2, 'po prawej');
INSERT INTO model VALUES (197, 24, '458-italia', 1, 5, 'po prawej');
INSERT INTO model VALUES (198, 69, 'latitude', 4, 5, 'po prawej');
INSERT INTO model VALUES (199, 88, 'golf-plus', 3, 7, 'po prawej');
INSERT INTO model VALUES (200, 82, 'avalon', 4, 3, 'po prawej');
INSERT INTO model VALUES (201, 57, 'tiida', 2, 4, 'po prawej');
INSERT INTO model VALUES (202, 75, 'superb', 1, 3, 'po prawej');
INSERT INTO model VALUES (203, 69, '21', 2, 4, 'po prawej');
INSERT INTO model VALUES (204, 15, 'chevy-van', 2, 8, 'po prawej');
INSERT INTO model VALUES (205, 3, '147', 2, 3, 'po prawej');
INSERT INTO model VALUES (206, 25, 'ducato', 1, 5, 'po prawej');
INSERT INTO model VALUES (207, 60, 'zafira', 2, 7, 'po prawej');
INSERT INTO model VALUES (208, 88, 'transporter', 4, 3, 'po prawej');
INSERT INTO model VALUES (209, 57, 'x-trail', 2, 3, 'po prawej');
INSERT INTO model VALUES (210, 25, 'regata', 2, 2, 'po prawej');
INSERT INTO model VALUES (211, 72, '9-2x', 2, 4, 'po prawej');
INSERT INTO model VALUES (212, 50, '270', 2, 5, 'po prawej');
INSERT INTO model VALUES (213, 78, 'brz', 2, 3, 'po prawej');
INSERT INTO model VALUES (214, 46, 'karif', 1, 3, 'po prawej');
INSERT INTO model VALUES (215, 61, '508', 1, 4, 'po prawej');
INSERT INTO model VALUES (216, 88, 'cc', 1, 6, 'po prawej');
INSERT INTO model VALUES (217, 20, 'matiz', 1, 3, 'po prawej');
INSERT INTO model VALUES (218, 50, '250', 1, 7, 'po prawej');
INSERT INTO model VALUES (219, 31, 'h200', 2, 6, 'po prawej');
INSERT INTO model VALUES (220, 13, 'brougham', 1, 3, 'po prawej');
INSERT INTO model VALUES (221, 50, '600', 1, 3, 'po prawej');
INSERT INTO model VALUES (222, 18, 's1', 3, 4, 'po prawej');
INSERT INTO model VALUES (223, 20, 'chairman', 1, 2, 'po prawej');
INSERT INTO model VALUES (224, 15, 'astro', 2, 6, 'po prawej');
INSERT INTO model VALUES (225, 7, 's6', 1, 7, 'po prawej');
INSERT INTO model VALUES (226, 26, 'f250', 2, 6, 'po prawej');
INSERT INTO model VALUES (227, 25, '126', 2, 4, 'po prawej');
INSERT INTO model VALUES (228, 2, 'a721', 1, 3, 'po prawej');
INSERT INTO model VALUES (229, 66, '968', 2, 4, 'po prawej');
INSERT INTO model VALUES (230, 34, 'xf', 2, 5, 'po prawej');
INSERT INTO model VALUES (231, 80, '102', 2, 4, 'po prawej');
INSERT INTO model VALUES (232, 16, 'saratoga', 1, 2, 'po prawej');
INSERT INTO model VALUES (233, 25, 'grande-punto', 1, 2, 'po prawej');
INSERT INTO model VALUES (234, 79, 'sj', 3, 6, 'po prawej');
INSERT INTO model VALUES (235, 31, 'i30', 1, 3, 'po prawej');
INSERT INTO model VALUES (236, 78, 'trezia', 1, 6, 'po prawej');
INSERT INTO model VALUES (237, 38, '2111', 4, 7, 'po prawej');
INSERT INTO model VALUES (238, 11, 'x3', 2, 5, 'po prawej');
INSERT INTO model VALUES (239, 45, 'esprit', 1, 8, 'po prawej');
INSERT INTO model VALUES (240, 76, 'roomster', 2, 2, 'po prawej');
INSERT INTO model VALUES (241, 25, 'strada', 2, 5, 'po prawej');
INSERT INTO model VALUES (242, 57, 'pixo', 2, 5, 'po prawej');
INSERT INTO model VALUES (243, 63, 'horizon', 2, 6, 'po prawej');
INSERT INTO model VALUES (244, 50, 'klasa-e', 1, 4, 'po prawej');
INSERT INTO model VALUES (245, 42, 'sc', 2, 5, 'po prawej');
INSERT INTO model VALUES (246, 65, 'fiero', 2, 3, 'po prawej');
INSERT INTO model VALUES (247, 24, '575', 2, 6, 'po prawej');
INSERT INTO model VALUES (248, 38, '2106', 1, 4, 'po prawej');
INSERT INTO model VALUES (249, 67, 'seria-400', 2, 2, 'po prawej');
INSERT INTO model VALUES (250, 37, 'sedona', 1, 2, 'po prawej');
INSERT INTO model VALUES (251, 40, 'stratos', 1, 3, 'po prawej');
INSERT INTO model VALUES (252, 35, 'cherokee', 1, 4, 'po prawej');
INSERT INTO model VALUES (253, 38, '2110', 1, 8, 'po prawej');
INSERT INTO model VALUES (254, 25, 'punto-evo', 3, 6, 'po prawej');
INSERT INTO model VALUES (255, 31, 'h-1', 1, 4, 'po prawej');
INSERT INTO model VALUES (256, 83, '601', 1, 2, 'po prawej');
INSERT INTO model VALUES (257, 50, 'w123', 4, 8, 'po prawej');
INSERT INTO model VALUES (258, 15, 'kalos', 3, 5, 'po prawej');
INSERT INTO model VALUES (259, 15, 'express', 4, 6, 'po prawej');
INSERT INTO model VALUES (260, 37, 'cerato', 3, 2, 'po prawej');
INSERT INTO model VALUES (261, 71, '400', 1, 4, 'po prawej');
INSERT INTO model VALUES (262, 11, 'x6-m', 2, 8, 'po prawej');
INSERT INTO model VALUES (263, 55, '3000gt', 2, 5, 'po prawej');
INSERT INTO model VALUES (264, 57, 'nv200', 1, 8, 'po prawej');
INSERT INTO model VALUES (265, 13, 'deville', 2, 4, 'po prawej');
INSERT INTO model VALUES (266, 16, 'pt-cruiser', 4, 5, 'po prawej');
INSERT INTO model VALUES (267, 69, 'safrane', 3, 7, 'po prawej');
INSERT INTO model VALUES (268, 73, 'altea-xl', 2, 4, 'po prawej');
INSERT INTO model VALUES (269, 50, '450', 1, 6, 'po prawej');
INSERT INTO model VALUES (270, 69, 'talisman', 1, 8, 'po prawej');
INSERT INTO model VALUES (271, 89, 'c70', 4, 2, 'po prawej');
INSERT INTO model VALUES (272, 69, 'wind', 2, 3, 'po prawej');
INSERT INTO model VALUES (273, 79, 'liana', 3, 3, 'po prawej');
INSERT INTO model VALUES (274, 48, 'cx-5', 2, 4, 'po prawej');
INSERT INTO model VALUES (275, 78, 'leone', 2, 4, 'po prawej');
INSERT INTO model VALUES (276, 20, 'lanos', 2, 2, 'po prawej');
INSERT INTO model VALUES (277, 25, 'ritmo', 2, 3, 'po prawej');
INSERT INTO model VALUES (278, 7, 's7', 4, 4, 'po prawej');
INSERT INTO model VALUES (279, 82, 'camry-solara', 1, 6, 'po prawej');
INSERT INTO model VALUES (280, 23, 'challenger', 1, 7, 'po prawej');
INSERT INTO model VALUES (281, 75, 'rapid', 2, 2, 'po prawej');
INSERT INTO model VALUES (282, 57, 'rogue', 2, 6, 'po prawej');
INSERT INTO model VALUES (283, 48, 'demio', 1, 5, 'po prawej');
INSERT INTO model VALUES (284, 35, 'liberty', 2, 2, 'po prawej');
INSERT INTO model VALUES (285, 26, 'crown', 2, 7, 'po prawej');
INSERT INTO model VALUES (286, 89, '480', 4, 7, 'po prawej');
INSERT INTO model VALUES (287, 77, 'tivoli', 2, 7, 'po prawej');
INSERT INTO model VALUES (288, 42, 'nx', 2, 5, 'po prawej');
INSERT INTO model VALUES (289, 63, 'fury', 1, 6, 'po prawej');
INSERT INTO model VALUES (290, 79, 'samurai', 2, 2, 'po prawej');
INSERT INTO model VALUES (291, 71, 'mini', 4, 3, 'po prawej');
INSERT INTO model VALUES (292, 57, 'murano', 1, 2, 'po prawej');
INSERT INTO model VALUES (293, 26, 'focus', 3, 7, 'po prawej');
INSERT INTO model VALUES (294, 35, 'commander', 1, 2, 'po prawej');
INSERT INTO model VALUES (295, 89, 'v60', 1, 6, 'po prawej');
INSERT INTO model VALUES (296, 88, 'passat', 2, 2, 'po prawej');
INSERT INTO model VALUES (297, 69, 'clio', 1, 7, 'po prawej');
INSERT INTO model VALUES (298, 55, 'asx', 1, 8, 'po prawej');
INSERT INTO model VALUES (299, 16, 'voyager', 2, 4, 'po prawej');
INSERT INTO model VALUES (300, 23, 'durango', 4, 2, 'po prawej');
INSERT INTO model VALUES (301, 66, 'carrera-gt', 2, 2, 'po prawej');
INSERT INTO model VALUES (302, 26, 'transit', 1, 4, 'po prawej');
INSERT INTO model VALUES (303, 46, 'indy', 3, 4, 'po prawej');
INSERT INTO model VALUES (304, 50, 'klasa-s', 1, 6, 'po prawej');
INSERT INTO model VALUES (305, 78, 'vivio', 1, 2, 'po prawej');
INSERT INTO model VALUES (306, 17, 'xsara-picasso', 1, 5, 'po prawej');
INSERT INTO model VALUES (307, 4, 'muscel', 2, 3, 'po prawej');
INSERT INTO model VALUES (308, 39, 'urraco', 4, 4, 'po prawej');
INSERT INTO model VALUES (309, 7, 'tt-s', 3, 7, 'po prawej');
INSERT INTO model VALUES (310, 82, 'picnic', 1, 5, 'po prawej');
INSERT INTO model VALUES (311, 37, 'rio', 4, 2, 'po prawej');
INSERT INTO model VALUES (312, 70, 'silver-shadow', 1, 2, 'po prawej');
INSERT INTO model VALUES (313, 89, 'xc-90', 2, 3, 'po prawej');
INSERT INTO model VALUES (314, 54, 'clubman', 4, 3, 'po prawej');
INSERT INTO model VALUES (315, 55, 'carisma', 4, 2, 'po prawej');
INSERT INTO model VALUES (316, 10, 'arnage', 4, 5, 'po prawej');
INSERT INTO model VALUES (317, 55, 'pajero-pinin', 2, 7, 'po prawej');
INSERT INTO model VALUES (318, 38, '110', 2, 3, 'po prawej');
INSERT INTO model VALUES (319, 3, '166', 1, 4, 'po prawej');
INSERT INTO model VALUES (320, 6, 'dbs', 2, 4, 'po prawej');
INSERT INTO model VALUES (321, 34, 'f-type', 1, 7, 'po prawej');
INSERT INTO model VALUES (322, 29, 'cr-z', 2, 2, 'po prawej');
INSERT INTO model VALUES (323, 15, 'c-20', 1, 7, 'po prawej');
INSERT INTO model VALUES (324, 16, 'grand-voyager', 2, 2, 'po prawej');
INSERT INTO model VALUES (325, 79, 'celerio', 1, 3, 'po prawej');
INSERT INTO model VALUES (326, 75, 'favorit', 1, 8, 'po prawej');
INSERT INTO model VALUES (327, 26, 'ka', 2, 8, 'po prawej');
INSERT INTO model VALUES (328, 29, 's-2000', 2, 6, 'po prawej');
INSERT INTO model VALUES (329, 88, 'kafer', 1, 8, 'po prawej');
INSERT INTO model VALUES (330, 2, 'a741', 1, 7, 'po prawej');
INSERT INTO model VALUES (331, 2, 'coupe', 2, 4, 'po prawej');
INSERT INTO model VALUES (332, 71, '620', 1, 5, 'po prawej');
INSERT INTO model VALUES (333, 42, 'lfa', 1, 3, 'po prawej');
INSERT INTO model VALUES (334, 19, 'super-nova', 1, 8, 'po prawej');
INSERT INTO model VALUES (335, 57, 'sentra', 1, 4, 'po prawej');
INSERT INTO model VALUES (336, 28, '67', 2, 3, 'po prawej');
INSERT INTO model VALUES (337, 31, 'grand-santa-fe', 3, 2, 'po prawej');
INSERT INTO model VALUES (338, 14, 'csr', 2, 8, 'po prawej');
INSERT INTO model VALUES (339, 31, 'accent', 1, 6, 'po prawej');
INSERT INTO model VALUES (340, 21, 'applause', 2, 7, 'po prawej');
INSERT INTO model VALUES (341, 69, 'avantime', 1, 6, 'po prawej');
INSERT INTO model VALUES (342, 61, '206-cc', 2, 7, 'po prawej');
INSERT INTO model VALUES (343, 25, 'ulysse', 2, 6, 'po prawej');
INSERT INTO model VALUES (344, 33, 'campo', 1, 7, 'po prawej');
INSERT INTO model VALUES (345, 7, '200', 2, 6, 'po prawej');
INSERT INTO model VALUES (346, 40, 'gamma', 2, 4, 'po prawej');
INSERT INTO model VALUES (347, 84, 'tr7', 2, 3, 'po prawej');
INSERT INTO model VALUES (348, 59, 'seria-500', 3, 7, 'po prawej');
INSERT INTO model VALUES (349, 61, '806', 4, 5, 'po prawej');
INSERT INTO model VALUES (350, 39, 'miura', 2, 7, 'po prawej');
INSERT INTO model VALUES (351, 24, 'laferrari', 1, 8, 'po prawej');
INSERT INTO model VALUES (352, 61, '306', 2, 4, 'po prawej');
INSERT INTO model VALUES (353, 88, 'polo', 1, 5, 'po prawej');
INSERT INTO model VALUES (354, 55, 'galant', 1, 8, 'po prawej');
INSERT INTO model VALUES (355, 17, 'jumper', 1, 8, 'po prawej');
INSERT INTO model VALUES (356, 78, 'legacy', 1, 2, 'po prawej');
INSERT INTO model VALUES (357, 61, 'partner', 4, 3, 'po prawej');
INSERT INTO model VALUES (358, 13, 'xlr-v', 2, 5, 'po prawej');
INSERT INTO model VALUES (359, 17, 'nemo', 1, 2, 'po prawej');
INSERT INTO model VALUES (360, 55, 'space-runner', 2, 7, 'po prawej');
INSERT INTO model VALUES (361, 25, '500', 2, 5, 'po prawej');
INSERT INTO model VALUES (362, 38, '2105', 2, 2, 'po prawej');
INSERT INTO model VALUES (363, 88, 'touareg', 1, 5, 'po prawej');
INSERT INTO model VALUES (364, 71, '218', 3, 3, 'po prawej');
INSERT INTO model VALUES (365, 26, 'bronco', 3, 4, 'po prawej');
INSERT INTO model VALUES (366, 39, 'lm', 4, 6, 'po prawej');
INSERT INTO model VALUES (367, 24, '330', 3, 3, 'po prawej');
INSERT INTO model VALUES (368, 26, 'tourneo-courier', 2, 3, 'po prawej');
INSERT INTO model VALUES (369, 50, '420', 4, 6, 'po prawej');
INSERT INTO model VALUES (370, 34, 'xjsc', 1, 5, 'po prawej');
INSERT INTO model VALUES (371, 55, 'tredia', 1, 5, 'po prawej');
INSERT INTO model VALUES (372, 79, 'reno', 2, 3, 'po prawej');
INSERT INTO model VALUES (373, 26, 'festiva', 2, 7, 'po prawej');
INSERT INTO model VALUES (374, 71, 'metro', 1, 6, 'po prawej');
INSERT INTO model VALUES (375, 22, 'dmc-12', 4, 3, 'po prawej');
INSERT INTO model VALUES (376, 82, 'avensis-verso', 1, 5, 'po prawej');
INSERT INTO model VALUES (377, 6, 'volatne', 3, 3, 'po prawej');
INSERT INTO model VALUES (378, 25, 'albea', 2, 7, 'po prawej');
INSERT INTO model VALUES (379, 61, '305', 2, 4, 'po prawej');
INSERT INTO model VALUES (380, 61, '106', 1, 6, 'po prawej');
INSERT INTO model VALUES (381, 82, 'paseo', 1, 5, 'po prawej');
INSERT INTO model VALUES (382, 46, 'biturbo', 1, 8, 'po prawej');
INSERT INTO model VALUES (383, 4, 'seria-240', 2, 6, 'po prawej');
INSERT INTO model VALUES (384, 37, 'sephia', 2, 6, 'po prawej');
INSERT INTO model VALUES (385, 82, 'sequoia', 1, 4, 'po prawej');
INSERT INTO model VALUES (386, 48, '323', 1, 8, 'po prawej');
INSERT INTO model VALUES (387, 57, 'juke', 2, 2, 'po prawej');
INSERT INTO model VALUES (388, 20, 'tacuma', 2, 2, 'po prawej');
INSERT INTO model VALUES (389, 69, 'grand-scenic', 1, 7, 'po prawej');
INSERT INTO model VALUES (390, 89, '245', 3, 5, 'po prawej');
INSERT INTO model VALUES (391, 89, '940', 3, 4, 'po prawej');
INSERT INTO model VALUES (392, 6, 'v12-vanquish', 1, 8, 'po prawej');
INSERT INTO model VALUES (393, 13, 'sts', 3, 2, 'po prawej');
INSERT INTO model VALUES (394, 3, '33', 2, 4, 'po prawej');
INSERT INTO model VALUES (395, 40, 'phedra', 1, 6, 'po prawej');
INSERT INTO model VALUES (396, 66, '959', 2, 5, 'po prawej');
INSERT INTO model VALUES (397, 88, 'corrado', 2, 5, 'po prawej');
INSERT INTO model VALUES (398, 23, 'stealth', 2, 5, 'po prawej');
INSERT INTO model VALUES (399, 69, '30', 1, 3, 'po prawej');
INSERT INTO model VALUES (400, 63, 'laser', 1, 4, 'po prawej');
INSERT INTO model VALUES (401, 7, 'a5', 2, 4, 'po prawej');
INSERT INTO model VALUES (402, 61, '404', 1, 8, 'po prawej');
INSERT INTO model VALUES (403, 25, 'bravo', 4, 8, 'po prawej');
INSERT INTO model VALUES (404, 82, 'auris', 4, 4, 'po prawej');
INSERT INTO model VALUES (405, 50, 'sl', 1, 4, 'po prawej');
INSERT INTO model VALUES (406, 19, 'duster', 3, 3, 'po prawej');
INSERT INTO model VALUES (407, 57, 'cherry', 2, 5, 'po prawej');
INSERT INTO model VALUES (408, 10, 'mulsanne', 3, 4, 'po prawej');
INSERT INTO model VALUES (409, 21, 'rocky', 2, 4, 'po prawej');
INSERT INTO model VALUES (410, 21, 'terios', 3, 7, 'po prawej');
INSERT INTO model VALUES (411, 88, 'california', 2, 5, 'po prawej');
INSERT INTO model VALUES (412, 11, 'z4', 2, 5, 'po prawej');
INSERT INTO model VALUES (413, 26, 'ranger', 1, 4, 'po prawej');
INSERT INTO model VALUES (414, 39, 'diablo', 1, 2, 'po prawej');
INSERT INTO model VALUES (415, 7, 'rs7', 4, 7, 'po prawej');
INSERT INTO model VALUES (416, 57, 'leaf', 2, 7, 'po prawej');
INSERT INTO model VALUES (417, 77, 'musso', 1, 5, 'po prawej');
INSERT INTO model VALUES (418, 58, '1000', 1, 7, 'po prawej');
INSERT INTO model VALUES (419, 38, '1500', 1, 7, 'po prawej');
INSERT INTO model VALUES (420, 31, 'pony', 3, 4, 'po prawej');
INSERT INTO model VALUES (421, 48, 'bt-50', 3, 8, 'po prawej');
INSERT INTO model VALUES (422, 40, 'dedra', 3, 5, 'po prawej');
INSERT INTO model VALUES (423, 86, '3153', 1, 3, 'po prawej');
INSERT INTO model VALUES (424, 91, '311', 4, 8, 'po prawej');
INSERT INTO model VALUES (425, 29, 'fr-v', 1, 3, 'po prawej');
INSERT INTO model VALUES (426, 8, 'ambasador', 3, 4, 'po prawej');
INSERT INTO model VALUES (427, 57, 'primera', 1, 4, 'po prawej');
INSERT INTO model VALUES (428, 11, 'seria-6', 2, 4, 'po prawej');
INSERT INTO model VALUES (429, 69, '18', 1, 5, 'po prawej');
INSERT INTO model VALUES (430, 89, 'v40', 4, 3, 'po prawej');
INSERT INTO model VALUES (431, 42, 'rx', 2, 4, 'po prawej');
INSERT INTO model VALUES (432, 10, 'azure', 2, 2, 'po prawej');
INSERT INTO model VALUES (433, 23, 'dart', 2, 7, 'po prawej');
INSERT INTO model VALUES (434, 69, 'modus', 2, 6, 'po prawej');
INSERT INTO model VALUES (435, 25, '125p', 2, 2, 'po prawej');
INSERT INTO model VALUES (436, 48, 'mx-3', 2, 8, 'po prawej');
INSERT INTO model VALUES (437, 69, '5', 2, 8, 'po prawej');
INSERT INTO model VALUES (438, 82, 'prius', 1, 4, 'po prawej');
INSERT INTO model VALUES (439, 89, '760', 2, 2, 'po prawej');
INSERT INTO model VALUES (440, 11, 'm5', 4, 3, 'po prawej');
INSERT INTO model VALUES (441, 25, 'uno', 1, 7, 'po prawej');
INSERT INTO model VALUES (442, 72, '9-5', 2, 5, 'po prawej');
INSERT INTO model VALUES (443, 79, 'swift', 2, 2, 'po prawej');
INSERT INTO model VALUES (444, 36, '47', 3, 4, 'po prawej');
INSERT INTO model VALUES (445, 48, 'millenia', 2, 3, 'po prawej');
INSERT INTO model VALUES (446, 60, 'commodore', 3, 5, 'po prawej');
INSERT INTO model VALUES (447, 66, '962', 3, 4, 'po prawej');
INSERT INTO model VALUES (448, 60, 'ampera', 2, 3, 'po prawej');
INSERT INTO model VALUES (449, 15, 'apache', 2, 5, 'po prawej');
INSERT INTO model VALUES (450, 55, 'l300', 2, 4, 'po prawej');
INSERT INTO model VALUES (451, 60, 'adam', 2, 6, 'po prawej');
INSERT INTO model VALUES (452, 26, 'contour', 2, 3, 'po prawej');
INSERT INTO model VALUES (453, 71, '214', 1, 8, 'po prawej');
INSERT INTO model VALUES (454, 73, 'marbella', 2, 3, 'po prawej');
INSERT INTO model VALUES (455, 72, '9000', 4, 6, 'po prawej');
INSERT INTO model VALUES (456, 15, 'cruze', 2, 6, 'po prawej');
INSERT INTO model VALUES (457, 7, '80', 1, 8, 'po prawej');
INSERT INTO model VALUES (458, 89, 'xc-70', 1, 2, 'po prawej');
INSERT INTO model VALUES (459, 89, '440', 2, 6, 'po prawej');
INSERT INTO model VALUES (460, 88, 'golf', 1, 8, 'po prawej');
INSERT INTO model VALUES (461, 7, 'a8', 2, 2, 'po prawej');
INSERT INTO model VALUES (462, 15, 'volt', 1, 5, 'po prawej');
INSERT INTO model VALUES (463, 26, 'mondeo', 1, 3, 'po prawej');
INSERT INTO model VALUES (464, 31, 'xg-350', 3, 6, 'po prawej');
INSERT INTO model VALUES (465, 29, 'odyssey', 2, 8, 'po prawej');
INSERT INTO model VALUES (466, 26, 'aerostar', 2, 4, 'po prawej');
INSERT INTO model VALUES (467, 65, 'gto', 1, 4, 'po prawej');
INSERT INTO model VALUES (468, 32, 'qx', 2, 2, 'po prawej');
INSERT INTO model VALUES (469, 72, '96', 3, 6, 'po prawej');
INSERT INTO model VALUES (470, 29, 'hr-v', 2, 2, 'po prawej');
INSERT INTO model VALUES (471, 15, 'avalanche', 1, 4, 'po prawej');
INSERT INTO model VALUES (472, 11, 'seria-7', 2, 6, 'po prawej');
INSERT INTO model VALUES (473, 69, 'alpine-v6', 1, 2, 'po prawej');
INSERT INTO model VALUES (474, 26, 'probe', 1, 5, 'po prawej');
INSERT INTO model VALUES (475, 26, 'focus-c-max', 3, 3, 'po prawej');
INSERT INTO model VALUES (476, 19, 'logan-van', 4, 6, 'po prawej');
INSERT INTO model VALUES (477, 45, 'exige', 2, 3, 'po prawej');
INSERT INTO model VALUES (478, 82, 'cressida', 2, 3, 'po prawej');
INSERT INTO model VALUES (479, 61, '1007', 1, 3, 'po prawej');
INSERT INTO model VALUES (480, 29, 'crx', 2, 5, 'po prawej');
INSERT INTO model VALUES (481, 61, '604', 2, 3, 'po prawej');
INSERT INTO model VALUES (482, 25, 'punto', 2, 7, 'po prawej');
INSERT INTO model VALUES (483, 61, '207', 3, 7, 'po prawej');
INSERT INTO model VALUES (484, 35, 'wagoneer', 2, 8, 'po prawej');
INSERT INTO model VALUES (485, 69, 'twingo', 1, 7, 'po prawej');
INSERT INTO model VALUES (486, 37, 'picanto', 1, 8, 'po prawej');
INSERT INTO model VALUES (487, 26, 'tempo', 1, 3, 'po prawej');
INSERT INTO model VALUES (488, 89, '460', 1, 5, 'po prawej');
INSERT INTO model VALUES (489, 79, 'xl7', 2, 6, 'po prawej');
INSERT INTO model VALUES (490, 16, 'neon', 1, 6, 'po prawej');
INSERT INTO model VALUES (491, 85, 'chimaera', 2, 6, 'po prawej');
INSERT INTO model VALUES (492, 11, 'i3', 4, 2, 'po prawej');
INSERT INTO model VALUES (493, 82, 'lite-ace', 2, 5, 'po prawej');
INSERT INTO model VALUES (494, 89, '264', 1, 3, 'po prawej');
INSERT INTO model VALUES (495, 69, 'fluence', 1, 4, 'po prawej');
INSERT INTO model VALUES (496, 19, '1310', 2, 4, 'po prawej');
INSERT INTO model VALUES (497, 11, 'i8', 1, 4, 'po prawej');
INSERT INTO model VALUES (498, 57, '370-z', 1, 5, 'po prawej');
INSERT INTO model VALUES (499, 48, 'seria-e', 2, 2, 'po prawej');
INSERT INTO model VALUES (500, 15, 'bel-air', 2, 8, 'po prawej');
INSERT INTO model VALUES (501, 3, '156', 2, 4, 'po prawej');
INSERT INTO model VALUES (502, 1, 'tsx', 1, 5, 'po prawej');
INSERT INTO model VALUES (503, 20, 'nexia', 1, 5, 'po prawej');
INSERT INTO model VALUES (504, 26, 'mercury', 1, 5, 'po prawej');
INSERT INTO model VALUES (505, 48, '6', 1, 8, 'po prawej');
INSERT INTO model VALUES (506, 38, '2101', 1, 4, 'po prawej');
INSERT INTO model VALUES (507, 44, 'continental', 2, 2, 'po prawej');
INSERT INTO model VALUES (508, 71, 'montego', 1, 5, 'po prawej');
INSERT INTO model VALUES (509, 38, '1200', 2, 2, 'po prawej');
INSERT INTO model VALUES (510, 32, 'q50', 1, 3, 'po prawej');
INSERT INTO model VALUES (511, 57, 'silvia', 2, 7, 'po prawej');
INSERT INTO model VALUES (512, 3, 'spider', 1, 3, 'po prawej');
INSERT INTO kierowcy VALUES (1, 87021508470, 'Maciej', 'Walczak', 'M', 'walczak.maciej@gmail.com', '641277220', 'Kusocińskiego', ' 1', '94-210', 174);
INSERT INTO kierowcy VALUES (2, 87032322940, 'Joanna', 'Andrzejewska', 'K', 'andrzejewska.joanna@wp.pl', '831131661', 'Os. Podzamcze', ' 1/73', '81-154', 335);
INSERT INTO kierowcy VALUES (3, 92021683050, 'Michał', 'Kubiak', 'M', 'kubiak.michal@interia.eu', '550804306', 'Zamiejska', ' 16', '11-500', 43);
INSERT INTO kierowcy VALUES (4, 87031231199, 'Hubert', 'Kamiński', 'M', 'kaminski.hubert@wp.pl', '722744008', 'Prof. Henryka Borka', ' 6', '48-188', 234);
INSERT INTO kierowcy VALUES (5, 90041775603, 'Nadia', 'Szczepańska', 'K', 'szczepanska.nadia@interia.eu', '885584065', 'Al. Róż', ' 4/55', '07-458', 176);
INSERT INTO kierowcy VALUES (6, 88032662759, 'Adrian', 'Olszewski', 'M', 'olszewski.adrian@wp.pl', '575775110', 'Lucjana Szenwalda', ' 0', '95-299', 165);
INSERT INTO kierowcy VALUES (7, 88080150718, 'Maksymilian', 'Szulc', 'M', 'szulc.maksymilian@interia.pl', '849068288', 'Modrzejewskiej', ' 19', '64-796', 10);
INSERT INTO kierowcy VALUES (8, 91063089165, 'Weronika', 'Lewandowska', 'K', 'lewandowska.weronika@o2.pl', '856461501', 'Chróścińska', ' 86/33', '64-787', 142);
INSERT INTO kierowcy VALUES (9, 89110758933, 'Natan', 'Majewski', 'M', 'majewski.natan@gmail.com', '724722577', 'Śliwkowa', ' 48', '21-262', 223);
INSERT INTO kierowcy VALUES (10, 90062743412, 'Piotr', 'Szulc', 'M', 'szulc.piotr@gmail.com', '570682313', 'Pawła Gwoździa', ' 72/8', '22-955', 95);
INSERT INTO kierowcy VALUES (11, 89060905146, 'Michalina', 'Borkowska', 'K', 'borkowska.michalina@interia.pl', '645683000', 'Krzemieniecka', ' 8', '61-522', 222);
INSERT INTO kierowcy VALUES (12, 96051231179, 'Adrian', 'Pawlak', 'M', 'pawlak.adrian@o2.pl', '789187470', 'Dekabrystów', ' 21', '64-844', 363);
INSERT INTO kierowcy VALUES (13, 89050631613, 'Bartłomiej', 'Mróz', 'M', 'mroz.bartlomiej@o2.pl', '859774668', 'Karłowiczki', ' 38/558', '35-131', 12);
INSERT INTO kierowcy VALUES (14, 89020677854, 'Marcel', 'Kwiatkowski', 'M', 'kwiatkowski.marcel@gmail.com', '594922922', 'Al. Róż', ' 1', '22-775', 339);
INSERT INTO kierowcy VALUES (15, 96021840057, 'Mikołaj', 'Pawlak', 'M', 'pawlak.mikolaj@gmail.com', '556225806', 'Jana Jana III Sobieskiego', ' 6', '60-013', 330);
INSERT INTO kierowcy VALUES (16, 87091386383, 'Kinga', 'Sokołowska', 'K', 'sokolowska.kinga@interia.eu', '760104437', 'Pszczelna', ' 6/28', '23-677', 308);
INSERT INTO kierowcy VALUES (17, 89072396844, 'Agata', 'Ostrowska', 'K', 'ostrowska.agata@wp.pl', '651843123', 'Al. III Tysiąclecia', ' 0', '60-455', 55);
INSERT INTO kierowcy VALUES (18, 96090484558, 'Aleksander', 'Mróz', 'M', 'mroz.aleksander@interia.pl', '888683186', 'Zawadzkiego', ' 9', '30-864', 139);
INSERT INTO kierowcy VALUES (19, 91103036324, 'Nadia', 'Zielińska', 'K', 'zielinska.nadia@interia.eu', '747075531', 'Pl. Floriana', ' 9/8', '31-265', 141);
INSERT INTO kierowcy VALUES (20, 89121103764, 'Nikola', 'Grabowska', 'K', 'grabowska.nikola@wp.pl', '666626313', 'Osiny', ' 59/587', '07-094', 350);
INSERT INTO kierowcy VALUES (21, 95092817740, 'Milena', 'Piotrowska', 'K', 'piotrowska.milena@wp.pl', '552774207', 'Przedpole', ' 1', '78-081', 28);
INSERT INTO kierowcy VALUES (22, 86010901849, 'Wiktoria', 'Adamczyk', 'K', 'adamczyk.wiktoria@interia.pl', '524954849', 'Łączna', ' 25', '34-405', 249);
INSERT INTO kierowcy VALUES (23, 94031141247, 'Maria', 'Zielińska', 'K', 'zielinska.maria@o2.pl', '529799393', 'Al. Wodna', ' 46', '81-535', 315);
INSERT INTO kierowcy VALUES (24, 96082595044, 'Maria', 'Olszewska', 'K', 'olszewska.maria@interia.eu', '854775584', 'Wieżowa', ' 12/32', '00-556', 302);
INSERT INTO kierowcy VALUES (25, 92010145017, 'Alan', 'Makowski', 'M', 'makowski.alan@o2.pl', '758215236', 'Dobrego Pasterza', ' 17/2', '40-804', 159);
INSERT INTO kierowcy VALUES (26, 89031527623, 'Patrycja', 'Adamczyk', 'K', 'adamczyk.patrycja@interia.eu', '645849247', 'Bartosza Głowackiego', ' 90', '01-370', 253);
INSERT INTO kierowcy VALUES (27, 91090719305, 'Marta', 'Michalak', 'K', 'michalak.marta@gmail.com', '554663460', 'Cementowa', ' 93', '86-997', 214);
INSERT INTO kierowcy VALUES (28, 89022798351, 'Piotr', 'Brzeziński', 'M', 'brzezinski.piotr@interia.eu', '753426425', 'Witolda Doroszewskiego', ' 1', '32-536', 189);
INSERT INTO kierowcy VALUES (29, 96063094403, 'Wiktoria', 'Pawlak', 'K', 'pawlak.wiktoria@gmail.com', '677631069', 'Azalii', ' 19', '26-839', 235);
INSERT INTO kierowcy VALUES (30, 94042028494, 'Karol', 'Wieczorek', 'M', 'wieczorek.karol@interia.pl', '520891129', 'Sobótki', ' 68', '86-569', 180);
INSERT INTO kierowcy VALUES (31, 93100575198, 'Leon', 'Kaczmarek', 'M', 'kaczmarek.leon@interia.pl', '895395103', 'Pisankowa', ' 3', '19-993', 358);
INSERT INTO kierowcy VALUES (32, 90061452094, 'Marcel', 'Szczepański', 'M', 'szczepanski.marcel@wp.pl', '808176139', 'Pl. Wiejski', ' 02', '74-925', 205);
INSERT INTO kierowcy VALUES (33, 95043043606, 'Barbara', 'Walczak', 'K', 'walczak.barbara@gmail.com', '756559415', 'Nad Złotym Potokiem', ' 8/702', '17-178', 212);
INSERT INTO kierowcy VALUES (34, 87071056428, 'Karolina', 'Dąbrowska', 'K', 'dabrowska.karolina@wp.pl', '593502585', 'Portowa', ' 0', '59-513', 271);
INSERT INTO kierowcy VALUES (35, 95072237742, 'Maja', 'Sadowska', 'K', 'sadowska.maja@o2.pl', '791585878', 'Poli Gojawiczyńskiej', ' 74', '23-087', 291);
INSERT INTO kierowcy VALUES (36, 93040835624, 'Antonina', 'Dudek', 'K', 'dudek.antonina@interia.eu', '709094217', 'Marcina Borelowskiego', ' 41/632', '06-744', 100);
INSERT INTO kierowcy VALUES (37, 94091811298, 'Julian', 'Malinowski', 'M', 'malinowski.julian@o2.pl', '629113259', 'Kolorowa', ' 5/178', '57-912', 268);
INSERT INTO kierowcy VALUES (38, 86053019534, 'Natan', 'Kamiński', 'M', 'kaminski.natan@wp.pl', '551619867', 'Bronisława Koraszewskiego', ' 78/96', '02-158', 96);
INSERT INTO kierowcy VALUES (39, 87090105903, 'Gabriela', 'Makowska', 'K', 'makowska.gabriela@interia.eu', '614336572', 'Augusta Bassego', ' 48', '86-738', 139);
INSERT INTO kierowcy VALUES (40, 91062622231, 'Szymon', 'Szewczyk', 'M', 'szewczyk.szymon@interia.pl', '572913127', 'Haliny Poświatowskiej', ' 16', '15-280', 60);
INSERT INTO kierowcy VALUES (41, 92091104769, 'Michalina', 'Pawlak', 'K', 'pawlak.michalina@wp.pl', '764223833', 'Karłubska', ' 7', '80-584', 4);
INSERT INTO kierowcy VALUES (42, 89121523157, 'Patryk', 'Urbański', 'M', 'urbanski.patryk@gmail.com', '587379536', 'Miechowska', ' 11/4', '20-079', 32);
INSERT INTO kierowcy VALUES (43, 89041615251, 'Adam', 'Mazur', 'M', 'mazur.adam@interia.pl', '759625427', 'Tadeusza Rejtana', ' 4', '53-785', 93);
INSERT INTO kierowcy VALUES (44, 91070821336, 'Karol', 'Baranowski', 'M', 'baranowski.karol@interia.pl', '789564053', 'Jana Kazimierza', ' 08', '79-552', 347);
INSERT INTO kierowcy VALUES (45, 95051149299, 'Kamil', 'Zieliński', 'M', 'zielinski.kamil@interia.eu', '644404034', 'Bocznicowa', ' 25', '71-629', 55);
INSERT INTO kierowcy VALUES (46, 86072038242, 'Kornelia', 'Sikorska', 'K', 'sikorska.kornelia@interia.eu', '699924232', 'Piłkarska', ' 1', '75-811', 82);
INSERT INTO kierowcy VALUES (47, 88020747244, 'Nadia', 'Adamska', 'K', 'adamska.nadia@interia.eu', '621033826', 'Śluza Wróblin', ' 3/3', '01-057', 21);
INSERT INTO kierowcy VALUES (48, 93112462286, 'Liliana', 'Maciejewska', 'K', 'maciejewska.liliana@interia.pl', '711543882', 'Józefa Wieczorka', ' 2', '45-896', 162);
INSERT INTO kierowcy VALUES (49, 96121298549, 'Iga', 'Kalinowska', 'K', 'kalinowska.iga@interia.eu', '892135641', 'Św. Józefa', ' 44', '90-329', 201);
INSERT INTO kierowcy VALUES (50, 92011707360, 'Iga', 'Tomaszewska', 'K', 'tomaszewska.iga@wp.pl', '778006547', 'Skalna', ' 6', '90-613', 310);
INSERT INTO kierowcy VALUES (51, 95110970837, 'Adam', 'Chmielewski', 'M', 'chmielewski.adam@o2.pl', '602836207', 'Blycharza Blicharza', ' 3', '03-054', 258);
INSERT INTO kierowcy VALUES (52, 92080278723, 'Agata', 'Król', 'K', 'krol.agata@o2.pl', '642293371', 'Partyzantów', ' 4/754', '73-476', 177);
INSERT INTO kierowcy VALUES (53, 96030417080, 'Dominika', 'Baranowska', 'K', 'baranowska.dominika@o2.pl', '547084865', 'Gierałtowska', ' 31/56', '68-470', 331);
INSERT INTO kierowcy VALUES (54, 95111723571, 'Alan', 'Czarnecki', 'M', 'czarnecki.alan@interia.pl', '771351595', 'Kukułcza', ' 4/356', '87-751', 94);
INSERT INTO kierowcy VALUES (55, 93012728677, 'Michał', 'Jakubowski', 'M', 'jakubowski.michal@gmail.com', '739070803', 'Henryka Pobożnego', ' 33', '28-200', 277);
INSERT INTO kierowcy VALUES (56, 86051587691, 'Oliwier', 'Błaszczyk', 'M', 'blaszczyk.oliwier@o2.pl', '815011822', 'Tetmajera', ' 61/96', '26-047', 109);
INSERT INTO kierowcy VALUES (57, 92022267394, 'Antoni', 'Pawłowski', 'M', 'pawlowski.antoni@o2.pl', '608414703', 'Bp. Schaffrana', ' 15', '41-128', 57);
INSERT INTO kierowcy VALUES (58, 90102708559, 'Kacper', 'Kowalski', 'M', 'kowalski.kacper@interia.pl', '679764697', 'Jana Kilińskiego', ' 53/86', '44-642', 155);
INSERT INTO kierowcy VALUES (59, 89111445812, 'Nikodem', 'Tomaszewski', 'M', 'tomaszewski.nikodem@interia.eu', '583658251', 'Gen. Pułaskiego', ' 02', '33-165', 102);
INSERT INTO kierowcy VALUES (60, 96022488140, 'Dominika', 'Bąk', 'K', 'bak.dominika@interia.pl', '807973347', 'Piwonii', ' 9', '06-288', 27);
INSERT INTO kierowcy VALUES (61, 94041788393, 'Ignacy', 'Olszewski', 'M', 'olszewski.ignacy@interia.pl', '577824287', 'Wieżowa', ' 83/838', '95-939', 154);
INSERT INTO kierowcy VALUES (62, 88021402153, 'Paweł', 'Adamski', 'M', 'adamski.pawel@interia.eu', '767263831', 'Granitowa', ' 34', '87-196', 229);
INSERT INTO kierowcy VALUES (63, 92110778359, 'Leon', 'Dąbrowski', 'M', 'dabrowski.leon@wp.pl', '812991645', 'Obozowa', ' 59', '30-887', 296);
INSERT INTO kierowcy VALUES (64, 96121090677, 'Szymon', 'Wojciechowski', 'M', 'wojciechowski.szymon@o2.pl', '881315889', 'Familijna', ' 5', '25-384', 14);
INSERT INTO kierowcy VALUES (65, 92021733052, 'Maciej', 'Borkowski', 'M', 'borkowski.maciej@o2.pl', '667639427', 'Marzatka', ' 3/6', '65-202', 90);
INSERT INTO kierowcy VALUES (66, 92052300030, 'Oliwier', 'Maciejewski', 'M', 'maciejewski.oliwier@wp.pl', '735029445', 'Szafirowa', ' 2/18', '86-960', 304);
INSERT INTO kierowcy VALUES (67, 92041524256, 'Mikołaj', 'Konieczny', 'M', 'konieczny.mikolaj@interia.eu', '655883471', 'Partnerstwa Bitburg', ' 92/14', '30-860', 76);
INSERT INTO kierowcy VALUES (68, 92033054943, 'Małgorzata', 'Laskowska', 'K', 'laskowska.malgorzata@interia.pl', '598812715', 'Celtycka', ' 54/49', '73-518', 200);
INSERT INTO kierowcy VALUES (69, 93120309304, 'Agata', 'Jabłońska', 'K', 'jablonska.agata@wp.pl', '827857746', 'Kępska', ' 59/52', '02-743', 23);
INSERT INTO kierowcy VALUES (70, 95062250504, 'Natalia', 'Głowacka', 'K', 'glowacka.natalia@o2.pl', '747280442', 'Bohaterów', ' 9', '84-055', 204);
INSERT INTO kierowcy VALUES (71, 94041011204, 'Dominika', 'Sawicka', 'K', 'sawicka.dominika@wp.pl', '633608104', 'Krucza', ' 82', '88-171', 349);
INSERT INTO kierowcy VALUES (72, 93091325613, 'Antoni', 'Kaczmarczyk', 'M', 'kaczmarczyk.antoni@interia.pl', '567748808', 'Pogodna', ' 8', '33-337', 201);
INSERT INTO kierowcy VALUES (73, 88010307144, 'Maria', 'Sikorska', 'K', 'sikorska.maria@o2.pl', '826758721', 'Czterdziestolecia', ' 4/238', '74-642', 92);
INSERT INTO kierowcy VALUES (74, 94031028494, 'Kajetan', 'Mazur', 'M', 'mazur.kajetan@o2.pl', '519241864', 'Lesiańska', ' 5', '29-624', 305);
INSERT INTO kierowcy VALUES (75, 88020622956, 'Paweł', 'Szulc', 'M', 'szulc.pawel@o2.pl', '523482134', 'Bocznobrzeska', ' 5', '47-590', 189);
INSERT INTO kierowcy VALUES (76, 86121549530, 'Kacper', 'Włodarczyk', 'M', 'wlodarczyk.kacper@interia.pl', '685128192', 'Banatki', ' 5', '68-304', 78);
INSERT INTO kierowcy VALUES (77, 90030493262, 'Dominika', 'Kubiak', 'K', 'kubiak.dominika@interia.pl', '608599494', 'Szemrowicka', ' 23', '69-364', 365);
INSERT INTO kierowcy VALUES (78, 89090833873, 'Oskar', 'Baranowski', 'M', 'baranowski.oskar@wp.pl', '516384318', 'Armii Krajowej AK', ' 4/15', '48-694', 283);
INSERT INTO kierowcy VALUES (79, 92071362965, 'Patrycja', 'Woźniak', 'K', 'wozniak.patrycja@o2.pl', '764666059', 'Gen. Dąbrowskiego', ' 20/3', '61-936', 319);
INSERT INTO kierowcy VALUES (80, 94102073110, 'Stanisław', 'Sikorski', 'M', 'sikorski.stanislaw@o2.pl', '849073345', 'Obrońców Pokoju', ' 2', '14-211', 281);
INSERT INTO kierowcy VALUES (81, 91082232320, 'Nikola', 'Lis', 'K', 'lis.nikola@interia.eu', '737098651', 'Opakowaniowa', ' 0', '09-832', 299);
INSERT INTO kierowcy VALUES (82, 86030678800, 'Aleksandra', 'Olszewska', 'K', 'olszewska.aleksandra@interia.eu', '750392794', 'Jana Matejki', ' 4', '57-584', 379);
INSERT INTO kierowcy VALUES (83, 87081843771, 'Leon', 'Czarnecki', 'M', 'czarnecki.leon@interia.eu', '823157023', 'Nefrytowa', ' 9', '21-581', 355);
INSERT INTO kierowcy VALUES (84, 94032141680, 'Wiktoria', 'Kowalczyk', 'K', 'kowalczyk.wiktoria@o2.pl', '642163992', 'Stara Kuźnia', ' 0/808', '82-046', 67);
INSERT INTO kierowcy VALUES (85, 87101438541, 'Anastazja', 'Adamczyk', 'K', 'adamczyk.anastazja@interia.eu', '756212370', 'Hibnera', ' 1', '37-486', 154);
INSERT INTO kierowcy VALUES (86, 92072620473, 'Krystian', 'Witkowski', 'M', 'witkowski.krystian@wp.pl', '821645759', 'Łukowa', ' 1/7', '41-357', 303);
INSERT INTO kierowcy VALUES (87, 89071663240, 'Liliana', 'Gajewska', 'K', 'gajewska.liliana@o2.pl', '748434360', 'Magnoliowa', ' 88', '07-706', 155);
INSERT INTO kierowcy VALUES (88, 96060784877, 'Adrian', 'Zieliński', 'M', 'zielinski.adrian@gmail.com', '851754724', 'Szymonowska', ' 04', '01-113', 321);
INSERT INTO kierowcy VALUES (89, 91120723759, 'Paweł', 'Michalski', 'M', 'michalski.pawel@interia.eu', '794598950', 'Gałczyńskiego', ' 1/5', '33-706', 159);
INSERT INTO kierowcy VALUES (90, 91030517266, 'Blanka', 'Kozłowska', 'K', 'kozlowska.blanka@wp.pl', '746790508', 'Kwiasowskiego', ' 6', '48-876', 40);
INSERT INTO kierowcy VALUES (91, 90090428507, 'Patrycja', 'Maciejewska', 'K', 'maciejewska.patrycja@interia.pl', '594552241', 'Ks. Gładysza', ' 35/856', '05-675', 130);
INSERT INTO kierowcy VALUES (92, 95050260997, 'Miłosz', 'Cieślak', 'M', 'cieslak.milosz@gmail.com', '577078749', 'Gałczyńskiego', ' 81', '08-815', 130);
INSERT INTO kierowcy VALUES (93, 96022168136, 'Szymon', 'Lewandowski', 'M', 'lewandowski.szymon@interia.eu', '540541172', 'Łączności', ' 64', '36-448', 227);
INSERT INTO kierowcy VALUES (94, 88012919163, 'Lena', 'Andrzejewska', 'K', 'andrzejewska.lena@o2.pl', '658527941', 'Obrowiecka', ' 8/897', '96-794', 78);
INSERT INTO kierowcy VALUES (95, 88121913414, 'Bartosz', 'Brzeziński', 'M', 'brzezinski.bartosz@interia.eu', '676986356', 'Sasanki', ' 59', '48-213', 194);
INSERT INTO kierowcy VALUES (96, 95120942299, 'Ksawery', 'Sikorski', 'M', 'sikorski.ksawery@wp.pl', '882648815', 'Gruntowa', ' 42', '82-419', 119);
INSERT INTO kierowcy VALUES (97, 96112227569, 'Julia', 'Makowska', 'K', 'makowska.julia@interia.eu', '644343715', 'Wisławy Szymborskiej', ' 4/49', '35-425', 62);
INSERT INTO kierowcy VALUES (98, 89021439118, 'Ksawery', 'Kowalski', 'M', 'kowalski.ksawery@interia.pl', '876270834', 'Św. Jacka', ' 29', '64-947', 154);
INSERT INTO kierowcy VALUES (99, 94020688289, 'Magdalena', 'Stępień', 'K', 'stepien.magdalena@wp.pl', '683440779', 'Kazimierza Kasperka', ' 53/630', '08-257', 27);
INSERT INTO kierowcy VALUES (100, 95101280488, 'Magdalena', 'Zalewska', 'K', 'zalewska.magdalena@wp.pl', '699497674', 'Kielecka', ' 2/3', '50-650', 92);
INSERT INTO egzaminy VALUES (1, '2005-05-10', 'teoria', 27, 4, 4, 1, 'zdal');
INSERT INTO egzaminy VALUES (2, '2005-05-17', 'praktyka', 31, 4, 4, 1, 'zdal');
INSERT INTO egzaminy VALUES (3, '2005-06-15', 'teoria', 27, 12, 4, 2, 'nie zdal');
INSERT INTO egzaminy VALUES (4, '2005-07-06', 'teoria', 24, 14, 4, 2, 'zdal');
INSERT INTO egzaminy VALUES (5, '2005-07-13', 'praktyka', 25, 10, 4, 2, 'zdal');
INSERT INTO egzaminy VALUES (6, '2005-07-06', 'teoria', 17, 2, 2, 2, 'zdal');
INSERT INTO egzaminy VALUES (7, '2005-07-13', 'praktyka', 11, 7, 2, 2, 'zdal');
INSERT INTO egzaminy VALUES (8, '2005-07-27', 'teoria', 16, 7, 7, 2, 'zdal');
INSERT INTO egzaminy VALUES (9, '2005-08-03', 'praktyka', 6, 13, 7, 2, 'zdal');
INSERT INTO egzaminy VALUES (10, '2010-05-11', 'teoria', 11, 15, 4, 3, 'nie zdal');
INSERT INTO egzaminy VALUES (11, '2010-06-01', 'teoria', 2, 5, 4, 3, 'zdal');
INSERT INTO egzaminy VALUES (12, '2010-06-08', 'praktyka', 13, 1, 4, 3, 'zdal');
INSERT INTO egzaminy VALUES (13, '2010-06-01', 'teoria', 18, 8, 3, 3, 'nie zdal');
INSERT INTO egzaminy VALUES (14, '2010-06-22', 'teoria', 9, 12, 3, 3, 'zdal');
INSERT INTO egzaminy VALUES (15, '2010-06-29', 'praktyka', 1, 16, 3, 3, 'nie zdal');
INSERT INTO egzaminy VALUES (16, '2010-07-20', 'praktyka', 25, 15, 3, 3, 'nie zdal');
INSERT INTO egzaminy VALUES (17, '2010-08-10', 'praktyka', 5, 6, 3, 3, 'zdal');
INSERT INTO egzaminy VALUES (18, '2005-06-04', 'teoria', 17, 10, 4, 4, 'zdal');
INSERT INTO egzaminy VALUES (19, '2005-06-11', 'praktyka', 13, 8, 4, 4, 'zdal');
INSERT INTO egzaminy VALUES (20, '2008-07-10', 'teoria', 31, 3, 4, 5, 'zdal');
INSERT INTO egzaminy VALUES (21, '2008-07-17', 'praktyka', 17, 9, 4, 5, 'zdal');
INSERT INTO egzaminy VALUES (22, '2008-07-31', 'teoria', 30, 3, 3, 5, 'zdal');
INSERT INTO egzaminy VALUES (23, '2008-08-07', 'praktyka', 30, 8, 3, 5, 'nie stawil sie');
INSERT INTO egzaminy VALUES (24, '2008-08-28', 'praktyka', 13, 7, 3, 5, 'nie zdal');
INSERT INTO egzaminy VALUES (25, '2008-09-18', 'praktyka', 8, 2, 3, 5, 'zdal');
INSERT INTO egzaminy VALUES (26, '2008-08-21', 'teoria', 29, 4, 3, 5, 'zdal');
INSERT INTO egzaminy VALUES (27, '2008-08-28', 'praktyka', 25, 1, 3, 5, 'nie zdal');
INSERT INTO egzaminy VALUES (28, '2008-09-18', 'praktyka', 21, 5, 3, 5, 'zdal');
INSERT INTO egzaminy VALUES (29, '2008-09-11', 'teoria', 1, 12, 1, 5, 'nie zdal');
INSERT INTO egzaminy VALUES (30, '2008-10-02', 'teoria', 26, 5, 1, 5, 'zdal');
INSERT INTO egzaminy VALUES (31, '2008-10-09', 'praktyka', 24, 6, 1, 5, 'nie zdal');
INSERT INTO egzaminy VALUES (32, '2008-10-30', 'praktyka', 12, 13, 1, 5, 'nie stawil sie');
INSERT INTO egzaminy VALUES (33, '2008-11-20', 'praktyka', 30, 4, 1, 5, 'zdal');
INSERT INTO egzaminy VALUES (34, '2006-06-18', 'teoria', 14, 5, 4, 6, 'nie zdal');
INSERT INTO egzaminy VALUES (35, '2006-07-09', 'teoria', 22, 5, 4, 6, 'zdal');
INSERT INTO egzaminy VALUES (36, '2006-07-16', 'praktyka', 15, 12, 4, 6, 'nie zdal');
INSERT INTO egzaminy VALUES (37, '2006-08-06', 'praktyka', 1, 5, 4, 6, 'nie zdal');
INSERT INTO egzaminy VALUES (38, '2006-08-27', 'praktyka', 14, 7, 4, 6, 'zdal');
INSERT INTO egzaminy VALUES (39, '2006-10-24', 'teoria', 23, 16, 4, 7, 'zdal');
INSERT INTO egzaminy VALUES (40, '2006-10-31', 'praktyka', 12, 16, 4, 7, 'zdal');
INSERT INTO egzaminy VALUES (41, '2009-09-22', 'teoria', 31, 14, 4, 8, 'nie zdal');
INSERT INTO egzaminy VALUES (42, '2009-10-13', 'teoria', 27, 4, 4, 8, 'zdal');
INSERT INTO egzaminy VALUES (43, '2009-10-20', 'praktyka', 17, 13, 4, 8, 'nie zdal');
INSERT INTO egzaminy VALUES (44, '2009-11-10', 'praktyka', 19, 16, 4, 8, 'zdal');
INSERT INTO egzaminy VALUES (45, '2009-10-13', 'teoria', 14, 6, 1, 8, 'nie zdal');
INSERT INTO egzaminy VALUES (46, '2009-11-03', 'teoria', 22, 10, 1, 8, 'zdal');
INSERT INTO egzaminy VALUES (47, '2009-11-10', 'praktyka', 27, 6, 1, 8, 'nie zdal');
INSERT INTO egzaminy VALUES (48, '2009-12-01', 'praktyka', 6, 6, 1, 8, 'nie zdal');
INSERT INTO egzaminy VALUES (49, '2009-12-22', 'praktyka', 6, 8, 1, 8, 'zdal');
INSERT INTO egzaminy VALUES (50, '2009-11-03', 'teoria', 21, 16, 7, 8, 'zdal');
INSERT INTO egzaminy VALUES (51, '2009-11-10', 'praktyka', 8, 4, 7, 8, 'nie zdal');
INSERT INTO egzaminy VALUES (52, '2009-12-01', 'praktyka', 25, 2, 7, 8, 'zdal');
INSERT INTO egzaminy VALUES (53, '2009-11-24', 'teoria', 23, 4, 2, 8, 'nie zdal');
INSERT INTO egzaminy VALUES (54, '2009-12-15', 'teoria', 18, 5, 2, 8, 'zdal');
INSERT INTO egzaminy VALUES (55, '2009-12-22', 'praktyka', 16, 3, 2, 8, 'nie zdal');
INSERT INTO egzaminy VALUES (56, '2010-01-12', 'praktyka', 14, 2, 2, 8, 'nie stawil sie');
INSERT INTO egzaminy VALUES (57, '2010-02-02', 'praktyka', 22, 4, 2, 8, 'zdal');
INSERT INTO egzaminy VALUES (58, '2008-01-30', 'teoria', 16, 14, 4, 9, 'zdal');
INSERT INTO egzaminy VALUES (59, '2008-02-06', 'praktyka', 14, 6, 4, 9, 'zdal');
INSERT INTO egzaminy VALUES (60, '2008-09-19', 'teoria', 3, 15, 4, 10, 'nie zdal');
INSERT INTO egzaminy VALUES (61, '2008-10-10', 'teoria', 12, 12, 4, 10, 'zdal');
INSERT INTO egzaminy VALUES (62, '2008-10-17', 'praktyka', 26, 16, 4, 10, 'nie zdal');
INSERT INTO egzaminy VALUES (63, '2008-11-07', 'praktyka', 5, 9, 4, 10, 'zdal');
INSERT INTO egzaminy VALUES (64, '2007-09-01', 'teoria', 1, 10, 4, 11, 'nie zdal');
INSERT INTO egzaminy VALUES (65, '2007-09-22', 'teoria', 1, 10, 4, 11, 'zdal');
INSERT INTO egzaminy VALUES (66, '2007-09-29', 'praktyka', 20, 9, 4, 11, 'nie zdal');
INSERT INTO egzaminy VALUES (67, '2007-10-20', 'praktyka', 4, 10, 4, 11, 'zdal');
INSERT INTO egzaminy VALUES (68, '2014-08-04', 'teoria', 14, 8, 4, 12, 'nie zdal');
INSERT INTO egzaminy VALUES (69, '2014-08-25', 'teoria', 1, 4, 4, 12, 'zdal');
INSERT INTO egzaminy VALUES (70, '2014-09-01', 'praktyka', 19, 15, 4, 12, 'nie zdal');
INSERT INTO egzaminy VALUES (71, '2014-09-22', 'praktyka', 17, 7, 4, 12, 'nie zdal');
INSERT INTO egzaminy VALUES (72, '2014-10-13', 'praktyka', 24, 1, 4, 12, 'zdal');
INSERT INTO egzaminy VALUES (73, '2007-07-29', 'teoria', 2, 12, 4, 13, 'zdal');
INSERT INTO egzaminy VALUES (74, '2007-08-05', 'praktyka', 18, 5, 4, 13, 'zdal');
INSERT INTO egzaminy VALUES (75, '2007-05-01', 'teoria', 2, 15, 4, 14, 'nie zdal');
INSERT INTO egzaminy VALUES (76, '2007-05-22', 'teoria', 28, 12, 4, 14, 'zdal');
INSERT INTO egzaminy VALUES (77, '2007-05-29', 'praktyka', 22, 10, 4, 14, 'nie zdal');
INSERT INTO egzaminy VALUES (78, '2007-06-19', 'praktyka', 19, 12, 4, 14, 'zdal');
INSERT INTO egzaminy VALUES (79, '2014-05-13', 'teoria', 22, 7, 4, 15, 'nie stawil sie');
INSERT INTO egzaminy VALUES (80, '2014-06-03', 'teoria', 9, 2, 4, 15, 'zdal');
INSERT INTO egzaminy VALUES (81, '2014-06-10', 'praktyka', 3, 14, 4, 15, 'nie zdal');
INSERT INTO egzaminy VALUES (82, '2014-07-01', 'praktyka', 14, 9, 4, 15, 'zdal');
INSERT INTO egzaminy VALUES (83, '2005-12-06', 'teoria', 15, 3, 4, 16, 'nie zdal');
INSERT INTO egzaminy VALUES (84, '2005-12-27', 'teoria', 3, 16, 4, 16, 'zdal');
INSERT INTO egzaminy VALUES (85, '2006-01-03', 'praktyka', 12, 14, 4, 16, 'zdal');
INSERT INTO egzaminy VALUES (86, '2007-10-15', 'teoria', 20, 1, 4, 17, 'nie zdal');
INSERT INTO egzaminy VALUES (87, '2007-11-05', 'teoria', 11, 13, 4, 17, 'zdal');
INSERT INTO egzaminy VALUES (88, '2007-11-12', 'praktyka', 15, 1, 4, 17, 'zdal');
INSERT INTO egzaminy VALUES (89, '2007-11-05', 'teoria', 3, 12, 5, 17, 'nie zdal');
INSERT INTO egzaminy VALUES (90, '2007-11-26', 'teoria', 30, 12, 5, 17, 'zdal');
INSERT INTO egzaminy VALUES (91, '2007-12-03', 'praktyka', 13, 10, 5, 17, 'zdal');
INSERT INTO egzaminy VALUES (92, '2014-11-27', 'teoria', 16, 3, 4, 18, 'nie zdal');
INSERT INTO egzaminy VALUES (93, '2014-12-18', 'teoria', 6, 9, 4, 18, 'zdal');
INSERT INTO egzaminy VALUES (94, '2014-12-25', 'praktyka', 13, 14, 4, 18, 'nie zdal');
INSERT INTO egzaminy VALUES (95, '2015-01-15', 'praktyka', 16, 7, 4, 18, 'zdal');
INSERT INTO egzaminy VALUES (96, '2010-01-22', 'teoria', 28, 11, 4, 19, 'nie zdal');
INSERT INTO egzaminy VALUES (97, '2010-02-12', 'teoria', 13, 10, 4, 19, 'zdal');
INSERT INTO egzaminy VALUES (98, '2010-02-19', 'praktyka', 2, 4, 4, 19, 'nie zdal');
INSERT INTO egzaminy VALUES (99, '2010-03-12', 'praktyka', 24, 5, 4, 19, 'zdal');
INSERT INTO egzaminy VALUES (100, '2008-03-04', 'teoria', 24, 7, 4, 20, 'nie zdal');
INSERT INTO egzaminy VALUES (101, '2008-03-25', 'teoria', 21, 7, 4, 20, 'zdal');
INSERT INTO egzaminy VALUES (102, '2008-04-01', 'praktyka', 16, 13, 4, 20, 'zdal');
INSERT INTO egzaminy VALUES (103, '2013-12-21', 'teoria', 31, 14, 4, 21, 'zdal');
INSERT INTO egzaminy VALUES (104, '2013-12-28', 'praktyka', 29, 1, 4, 21, 'nie zdal');
INSERT INTO egzaminy VALUES (105, '2014-01-18', 'praktyka', 6, 7, 4, 21, 'nie stawil sie');
INSERT INTO egzaminy VALUES (106, '2014-02-08', 'praktyka', 10, 5, 4, 21, 'zdal');
INSERT INTO egzaminy VALUES (107, '2014-01-11', 'teoria', 19, 3, 7, 21, 'zdal');
INSERT INTO egzaminy VALUES (108, '2014-01-18', 'praktyka', 26, 4, 7, 21, 'zdal');
INSERT INTO egzaminy VALUES (109, '2004-04-02', 'teoria', 32, 8, 4, 22, 'zdal');
INSERT INTO egzaminy VALUES (110, '2004-04-09', 'praktyka', 24, 12, 4, 22, 'nie zdal');
INSERT INTO egzaminy VALUES (111, '2004-04-30', 'praktyka', 2, 16, 4, 22, 'nie stawil sie');
INSERT INTO egzaminy VALUES (112, '2004-05-21', 'praktyka', 1, 9, 4, 22, 'zdal');
INSERT INTO egzaminy VALUES (113, '2012-06-03', 'teoria', 23, 13, 4, 23, 'nie zdal');
INSERT INTO egzaminy VALUES (114, '2012-06-24', 'teoria', 28, 11, 4, 23, 'zdal');
INSERT INTO egzaminy VALUES (115, '2012-07-01', 'praktyka', 14, 16, 4, 23, 'nie stawil sie');
INSERT INTO egzaminy VALUES (116, '2012-07-22', 'praktyka', 23, 4, 4, 23, 'zdal');
INSERT INTO egzaminy VALUES (117, '2014-11-17', 'teoria', 28, 10, 4, 24, 'nie zdal');
INSERT INTO egzaminy VALUES (118, '2014-12-08', 'teoria', 13, 3, 4, 24, 'zdal');
INSERT INTO egzaminy VALUES (119, '2014-12-15', 'praktyka', 6, 11, 4, 24, 'nie stawil sie');
INSERT INTO egzaminy VALUES (120, '2015-01-05', 'praktyka', 16, 3, 4, 24, 'zdal');
INSERT INTO egzaminy VALUES (121, '2010-03-26', 'teoria', 6, 13, 4, 25, 'zdal');
INSERT INTO egzaminy VALUES (122, '2010-04-02', 'praktyka', 21, 12, 4, 25, 'nie zdal');
INSERT INTO egzaminy VALUES (123, '2010-04-23', 'praktyka', 7, 3, 4, 25, 'zdal');
INSERT INTO egzaminy VALUES (124, '2007-06-07', 'teoria', 21, 9, 4, 26, 'zdal');
INSERT INTO egzaminy VALUES (125, '2007-06-14', 'praktyka', 24, 2, 4, 26, 'nie zdal');
INSERT INTO egzaminy VALUES (126, '2007-07-05', 'praktyka', 23, 3, 4, 26, 'zdal');
INSERT INTO egzaminy VALUES (127, '2009-11-30', 'teoria', 16, 5, 4, 27, 'nie stawil sie');
INSERT INTO egzaminy VALUES (128, '2009-12-21', 'teoria', 32, 7, 4, 27, 'zdal');
INSERT INTO egzaminy VALUES (129, '2009-12-28', 'praktyka', 14, 13, 4, 27, 'nie zdal');
INSERT INTO egzaminy VALUES (130, '2010-01-18', 'praktyka', 14, 16, 4, 27, 'zdal');
INSERT INTO egzaminy VALUES (131, '2007-05-22', 'teoria', 13, 16, 4, 28, 'nie zdal');
INSERT INTO egzaminy VALUES (132, '2007-06-12', 'teoria', 10, 3, 4, 28, 'zdal');
INSERT INTO egzaminy VALUES (133, '2007-06-19', 'praktyka', 14, 14, 4, 28, 'zdal');
INSERT INTO egzaminy VALUES (134, '2014-09-22', 'teoria', 2, 5, 4, 29, 'zdal');
INSERT INTO egzaminy VALUES (135, '2014-09-29', 'praktyka', 3, 16, 4, 29, 'zdal');
INSERT INTO egzaminy VALUES (136, '2012-07-13', 'teoria', 4, 9, 4, 30, 'zdal');
INSERT INTO egzaminy VALUES (137, '2012-07-20', 'praktyka', 11, 5, 4, 30, 'nie zdal');
INSERT INTO egzaminy VALUES (138, '2012-08-10', 'praktyka', 27, 12, 4, 30, 'zdal');
INSERT INTO egzaminy VALUES (139, '2011-12-28', 'teoria', 30, 14, 4, 31, 'nie zdal');
INSERT INTO egzaminy VALUES (140, '2012-01-18', 'teoria', 2, 7, 4, 31, 'zdal');
INSERT INTO egzaminy VALUES (141, '2012-01-25', 'praktyka', 3, 8, 4, 31, 'zdal');
INSERT INTO egzaminy VALUES (142, '2008-09-06', 'teoria', 3, 1, 4, 32, 'nie zdal');
INSERT INTO egzaminy VALUES (143, '2008-09-27', 'teoria', 26, 16, 4, 32, 'zdal');
INSERT INTO egzaminy VALUES (144, '2008-10-04', 'praktyka', 1, 14, 4, 32, 'zdal');
INSERT INTO egzaminy VALUES (145, '2008-09-27', 'teoria', 29, 4, 5, 32, 'zdal');
INSERT INTO egzaminy VALUES (146, '2008-10-04', 'praktyka', 24, 13, 5, 32, 'zdal');
INSERT INTO egzaminy VALUES (147, '2013-07-23', 'teoria', 17, 16, 4, 33, 'nie zdal');
INSERT INTO egzaminy VALUES (148, '2013-08-13', 'teoria', 12, 2, 4, 33, 'zdal');
INSERT INTO egzaminy VALUES (149, '2013-08-20', 'praktyka', 10, 4, 4, 33, 'nie stawil sie');
INSERT INTO egzaminy VALUES (150, '2013-09-10', 'praktyka', 14, 16, 4, 33, 'zdal');
INSERT INTO egzaminy VALUES (151, '2005-10-02', 'teoria', 1, 14, 4, 34, 'zdal');
INSERT INTO egzaminy VALUES (152, '2005-10-09', 'praktyka', 27, 2, 4, 34, 'zdal');
INSERT INTO egzaminy VALUES (153, '2013-10-14', 'teoria', 4, 16, 4, 35, 'zdal');
INSERT INTO egzaminy VALUES (154, '2013-10-21', 'praktyka', 10, 16, 4, 35, 'zdal');
INSERT INTO egzaminy VALUES (155, '2011-07-01', 'teoria', 1, 13, 4, 36, 'nie zdal');
INSERT INTO egzaminy VALUES (156, '2011-07-22', 'teoria', 27, 15, 4, 36, 'zdal');
INSERT INTO egzaminy VALUES (157, '2011-07-29', 'praktyka', 23, 14, 4, 36, 'zdal');
INSERT INTO egzaminy VALUES (158, '2011-07-22', 'teoria', 32, 14, 1, 36, 'nie zdal');
INSERT INTO egzaminy VALUES (159, '2011-08-12', 'teoria', 11, 7, 1, 36, 'zdal');
INSERT INTO egzaminy VALUES (160, '2011-08-19', 'praktyka', 9, 15, 1, 36, 'zdal');
INSERT INTO egzaminy VALUES (161, '2012-12-11', 'teoria', 32, 14, 4, 37, 'nie zdal');
INSERT INTO egzaminy VALUES (162, '2013-01-01', 'teoria', 27, 1, 4, 37, 'zdal');
INSERT INTO egzaminy VALUES (163, '2013-01-08', 'praktyka', 11, 7, 4, 37, 'zdal');
INSERT INTO egzaminy VALUES (164, '2004-08-22', 'teoria', 22, 1, 4, 38, 'zdal');
INSERT INTO egzaminy VALUES (165, '2004-08-29', 'praktyka', 19, 9, 4, 38, 'zdal');
INSERT INTO egzaminy VALUES (166, '2004-09-12', 'teoria', 24, 8, 6, 38, 'zdal');
INSERT INTO egzaminy VALUES (167, '2004-09-19', 'praktyka', 31, 10, 6, 38, 'zdal');
INSERT INTO egzaminy VALUES (168, '2004-10-03', 'teoria', 9, 1, 3, 38, 'zdal');
INSERT INTO egzaminy VALUES (169, '2004-10-10', 'praktyka', 8, 16, 3, 38, 'nie stawil sie');
INSERT INTO egzaminy VALUES (170, '2004-10-31', 'praktyka', 17, 2, 3, 38, 'nie zdal');
INSERT INTO egzaminy VALUES (171, '2004-11-21', 'praktyka', 15, 8, 3, 38, 'zdal');
INSERT INTO egzaminy VALUES (172, '2005-11-24', 'teoria', 9, 5, 4, 39, 'zdal');
INSERT INTO egzaminy VALUES (173, '2005-12-01', 'praktyka', 3, 6, 4, 39, 'nie stawil sie');
INSERT INTO egzaminy VALUES (174, '2005-12-22', 'praktyka', 28, 5, 4, 39, 'zdal');
INSERT INTO egzaminy VALUES (175, '2009-09-18', 'teoria', 28, 15, 4, 40, 'nie zdal');
INSERT INTO egzaminy VALUES (176, '2009-10-09', 'teoria', 3, 7, 4, 40, 'zdal');
INSERT INTO egzaminy VALUES (177, '2009-10-16', 'praktyka', 30, 7, 4, 40, 'nie zdal');
INSERT INTO egzaminy VALUES (178, '2009-11-06', 'praktyka', 6, 8, 4, 40, 'zdal');
INSERT INTO egzaminy VALUES (179, '2010-12-04', 'teoria', 24, 4, 4, 41, 'nie zdal');
INSERT INTO egzaminy VALUES (180, '2010-12-25', 'teoria', 17, 2, 4, 41, 'zdal');
INSERT INTO egzaminy VALUES (181, '2011-01-01', 'praktyka', 25, 16, 4, 41, 'zdal');
INSERT INTO egzaminy VALUES (182, '2008-03-08', 'teoria', 30, 8, 4, 42, 'nie zdal');
INSERT INTO egzaminy VALUES (183, '2008-03-29', 'teoria', 10, 11, 4, 42, 'zdal');
INSERT INTO egzaminy VALUES (184, '2008-04-05', 'praktyka', 30, 7, 4, 42, 'nie zdal');
INSERT INTO egzaminy VALUES (185, '2008-04-26', 'praktyka', 1, 8, 4, 42, 'zdal');
INSERT INTO egzaminy VALUES (186, '2008-03-29', 'teoria', 2, 13, 8, 42, 'zdal');
INSERT INTO egzaminy VALUES (187, '2008-04-05', 'praktyka', 7, 2, 8, 42, 'zdal');
INSERT INTO egzaminy VALUES (188, '2007-07-09', 'teoria', 22, 5, 4, 43, 'nie zdal');
INSERT INTO egzaminy VALUES (189, '2007-07-30', 'teoria', 17, 10, 4, 43, 'zdal');
INSERT INTO egzaminy VALUES (190, '2007-08-06', 'praktyka', 16, 13, 4, 43, 'nie zdal');
INSERT INTO egzaminy VALUES (191, '2007-08-27', 'praktyka', 29, 9, 4, 43, 'nie zdal');
INSERT INTO egzaminy VALUES (192, '2007-09-17', 'praktyka', 9, 16, 4, 43, 'zdal');
INSERT INTO egzaminy VALUES (193, '2009-09-30', 'teoria', 21, 10, 4, 44, 'nie zdal');
INSERT INTO egzaminy VALUES (194, '2009-10-21', 'teoria', 16, 5, 4, 44, 'zdal');
INSERT INTO egzaminy VALUES (195, '2009-10-28', 'praktyka', 30, 11, 4, 44, 'zdal');
INSERT INTO egzaminy VALUES (196, '2009-10-21', 'teoria', 21, 4, 1, 44, 'zdal');
INSERT INTO egzaminy VALUES (197, '2009-10-28', 'praktyka', 24, 14, 1, 44, 'zdal');
INSERT INTO egzaminy VALUES (198, '2013-08-03', 'teoria', 2, 5, 4, 45, 'nie zdal');
INSERT INTO egzaminy VALUES (199, '2013-08-24', 'teoria', 13, 15, 4, 45, 'zdal');
INSERT INTO egzaminy VALUES (200, '2013-08-31', 'praktyka', 3, 8, 4, 45, 'zdal');
INSERT INTO egzaminy VALUES (201, '2004-10-12', 'teoria', 9, 13, 4, 46, 'zdal');
INSERT INTO egzaminy VALUES (202, '2004-10-19', 'praktyka', 10, 7, 4, 46, 'zdal');
INSERT INTO egzaminy VALUES (203, '2006-05-02', 'teoria', 7, 3, 4, 47, 'zdal');
INSERT INTO egzaminy VALUES (204, '2006-05-09', 'praktyka', 21, 3, 4, 47, 'nie zdal');
INSERT INTO egzaminy VALUES (205, '2006-05-30', 'praktyka', 9, 8, 4, 47, 'zdal');
INSERT INTO egzaminy VALUES (206, '2012-02-16', 'teoria', 1, 9, 4, 48, 'nie stawil sie');
INSERT INTO egzaminy VALUES (207, '2012-03-08', 'teoria', 11, 8, 4, 48, 'zdal');
INSERT INTO egzaminy VALUES (208, '2012-03-15', 'praktyka', 2, 3, 4, 48, 'nie zdal');
INSERT INTO egzaminy VALUES (209, '2012-04-05', 'praktyka', 25, 3, 4, 48, 'zdal');
INSERT INTO egzaminy VALUES (210, '2015-03-06', 'teoria', 18, 5, 4, 49, 'nie stawil sie');
INSERT INTO egzaminy VALUES (211, '2015-03-27', 'teoria', 3, 14, 4, 49, 'zdal');
INSERT INTO egzaminy VALUES (212, '2015-04-03', 'praktyka', 29, 1, 4, 49, 'nie stawil sie');
INSERT INTO egzaminy VALUES (213, '2015-04-24', 'praktyka', 12, 15, 4, 49, 'zdal');
INSERT INTO egzaminy VALUES (214, '2015-03-27', 'teoria', 8, 8, 2, 49, 'nie stawil sie');
INSERT INTO egzaminy VALUES (215, '2015-04-17', 'teoria', 13, 13, 2, 49, 'zdal');
INSERT INTO egzaminy VALUES (216, '2015-04-24', 'praktyka', 16, 8, 2, 49, 'nie zdal');
INSERT INTO egzaminy VALUES (217, '2015-05-15', 'praktyka', 10, 3, 2, 49, 'nie zdal');
INSERT INTO egzaminy VALUES (218, '2015-06-05', 'praktyka', 1, 6, 2, 49, 'zdal');
INSERT INTO egzaminy VALUES (219, '2015-04-17', 'teoria', 31, 8, 8, 49, 'zdal');
INSERT INTO egzaminy VALUES (220, '2015-04-24', 'praktyka', 13, 8, 8, 49, 'nie zdal');
INSERT INTO egzaminy VALUES (221, '2015-05-15', 'praktyka', 27, 7, 8, 49, 'nie zdal');
INSERT INTO egzaminy VALUES (222, '2015-06-05', 'praktyka', 10, 14, 8, 49, 'zdal');
INSERT INTO egzaminy VALUES (223, '2010-04-11', 'teoria', 15, 9, 4, 50, 'zdal');
INSERT INTO egzaminy VALUES (224, '2010-04-18', 'praktyka', 26, 10, 4, 50, 'zdal');
INSERT INTO egzaminy VALUES (225, '2014-02-01', 'teoria', 3, 7, 4, 51, 'nie stawil sie');
INSERT INTO egzaminy VALUES (226, '2014-02-22', 'teoria', 16, 13, 4, 51, 'zdal');
INSERT INTO egzaminy VALUES (227, '2014-03-01', 'praktyka', 25, 10, 4, 51, 'zdal');
INSERT INTO egzaminy VALUES (228, '2014-02-22', 'teoria', 10, 9, 3, 51, 'nie zdal');
INSERT INTO egzaminy VALUES (229, '2014-03-15', 'teoria', 16, 2, 3, 51, 'zdal');
INSERT INTO egzaminy VALUES (230, '2014-03-22', 'praktyka', 31, 11, 3, 51, 'zdal');
INSERT INTO egzaminy VALUES (231, '2014-03-15', 'teoria', 16, 8, 1, 51, 'zdal');
INSERT INTO egzaminy VALUES (232, '2014-03-22', 'praktyka', 23, 4, 1, 51, 'nie zdal');
INSERT INTO egzaminy VALUES (233, '2014-04-12', 'praktyka', 21, 2, 1, 51, 'nie zdal');
INSERT INTO egzaminy VALUES (234, '2014-05-03', 'praktyka', 9, 14, 1, 51, 'zdal');
INSERT INTO egzaminy VALUES (235, '2010-10-25', 'teoria', 8, 2, 4, 52, 'nie zdal');
INSERT INTO egzaminy VALUES (236, '2010-11-15', 'teoria', 20, 11, 4, 52, 'zdal');
INSERT INTO egzaminy VALUES (237, '2010-11-22', 'praktyka', 19, 9, 4, 52, 'zdal');
INSERT INTO egzaminy VALUES (238, '2014-05-27', 'teoria', 11, 15, 4, 53, 'zdal');
INSERT INTO egzaminy VALUES (239, '2014-06-03', 'praktyka', 6, 9, 4, 53, 'nie stawil sie');
INSERT INTO egzaminy VALUES (240, '2014-06-24', 'praktyka', 4, 7, 4, 53, 'zdal');
INSERT INTO egzaminy VALUES (241, '2014-02-09', 'teoria', 4, 13, 4, 54, 'nie stawil sie');
INSERT INTO egzaminy VALUES (242, '2014-03-02', 'teoria', 23, 16, 4, 54, 'zdal');
INSERT INTO egzaminy VALUES (243, '2014-03-09', 'praktyka', 21, 1, 4, 54, 'zdal');
INSERT INTO egzaminy VALUES (244, '2011-04-21', 'teoria', 21, 2, 4, 55, 'zdal');
INSERT INTO egzaminy VALUES (245, '2011-04-28', 'praktyka', 2, 14, 4, 55, 'zdal');
INSERT INTO egzaminy VALUES (246, '2011-05-12', 'teoria', 2, 10, 3, 55, 'nie stawil sie');
INSERT INTO egzaminy VALUES (247, '2011-06-02', 'teoria', 26, 16, 3, 55, 'zdal');
INSERT INTO egzaminy VALUES (248, '2011-06-09', 'praktyka', 27, 1, 3, 55, 'zdal');
INSERT INTO egzaminy VALUES (249, '2004-08-07', 'teoria', 13, 12, 4, 56, 'zdal');
INSERT INTO egzaminy VALUES (250, '2004-08-14', 'praktyka', 3, 5, 4, 56, 'zdal');
INSERT INTO egzaminy VALUES (251, '2010-05-17', 'teoria', 8, 16, 4, 57, 'zdal');
INSERT INTO egzaminy VALUES (252, '2010-05-24', 'praktyka', 24, 5, 4, 57, 'zdal');
INSERT INTO egzaminy VALUES (253, '2009-01-19', 'teoria', 19, 10, 4, 58, 'nie zdal');
INSERT INTO egzaminy VALUES (254, '2009-02-09', 'teoria', 27, 13, 4, 58, 'zdal');
INSERT INTO egzaminy VALUES (255, '2009-02-16', 'praktyka', 12, 13, 4, 58, 'nie zdal');
INSERT INTO egzaminy VALUES (256, '2009-03-09', 'praktyka', 3, 13, 4, 58, 'nie zdal');
INSERT INTO egzaminy VALUES (257, '2009-03-30', 'praktyka', 7, 8, 4, 58, 'zdal');
INSERT INTO egzaminy VALUES (258, '2008-02-06', 'teoria', 27, 16, 4, 59, 'nie zdal');
INSERT INTO egzaminy VALUES (259, '2008-02-27', 'teoria', 11, 6, 4, 59, 'zdal');
INSERT INTO egzaminy VALUES (260, '2008-03-05', 'praktyka', 25, 6, 4, 59, 'nie zdal');
INSERT INTO egzaminy VALUES (261, '2008-03-26', 'praktyka', 15, 9, 4, 59, 'nie stawil sie');
INSERT INTO egzaminy VALUES (262, '2008-04-16', 'praktyka', 21, 11, 4, 59, 'zdal');
INSERT INTO egzaminy VALUES (263, '2008-02-27', 'teoria', 22, 13, 3, 59, 'zdal');
INSERT INTO egzaminy VALUES (264, '2008-03-05', 'praktyka', 30, 14, 3, 59, 'zdal');
INSERT INTO egzaminy VALUES (265, '2008-03-19', 'teoria', 29, 10, 5, 59, 'nie zdal');
INSERT INTO egzaminy VALUES (266, '2008-04-09', 'teoria', 23, 15, 5, 59, 'zdal');
INSERT INTO egzaminy VALUES (267, '2008-04-16', 'praktyka', 18, 8, 5, 59, 'zdal');
INSERT INTO egzaminy VALUES (268, '2008-04-09', 'teoria', 9, 1, 1, 59, 'zdal');
INSERT INTO egzaminy VALUES (269, '2008-04-16', 'praktyka', 22, 5, 1, 59, 'zdal');
INSERT INTO egzaminy VALUES (270, '2014-05-19', 'teoria', 1, 6, 4, 60, 'nie zdal');
INSERT INTO egzaminy VALUES (271, '2014-06-09', 'teoria', 10, 11, 4, 60, 'zdal');
INSERT INTO egzaminy VALUES (272, '2014-06-16', 'praktyka', 16, 6, 4, 60, 'nie zdal');
INSERT INTO egzaminy VALUES (273, '2014-07-07', 'praktyka', 2, 9, 4, 60, 'nie stawil sie');
INSERT INTO egzaminy VALUES (274, '2014-07-28', 'praktyka', 28, 5, 4, 60, 'zdal');
INSERT INTO egzaminy VALUES (275, '2014-06-09', 'teoria', 9, 7, 3, 60, 'nie zdal');
INSERT INTO egzaminy VALUES (276, '2014-06-30', 'teoria', 20, 1, 3, 60, 'zdal');
INSERT INTO egzaminy VALUES (277, '2014-07-07', 'praktyka', 24, 10, 3, 60, 'zdal');
INSERT INTO egzaminy VALUES (278, '2014-06-30', 'teoria', 24, 13, 6, 60, 'nie stawil sie');
INSERT INTO egzaminy VALUES (279, '2014-07-21', 'teoria', 8, 14, 6, 60, 'zdal');
INSERT INTO egzaminy VALUES (280, '2014-07-28', 'praktyka', 16, 7, 6, 60, 'zdal');
INSERT INTO egzaminy VALUES (281, '2012-07-10', 'teoria', 12, 2, 4, 61, 'nie zdal');
INSERT INTO egzaminy VALUES (282, '2012-07-31', 'teoria', 1, 9, 4, 61, 'zdal');
INSERT INTO egzaminy VALUES (283, '2012-08-07', 'praktyka', 16, 11, 4, 61, 'zdal');
INSERT INTO egzaminy VALUES (284, '2012-07-31', 'teoria', 24, 10, 5, 61, 'nie zdal');
INSERT INTO egzaminy VALUES (285, '2012-08-21', 'teoria', 3, 8, 5, 61, 'zdal');
INSERT INTO egzaminy VALUES (286, '2012-08-28', 'praktyka', 1, 10, 5, 61, 'nie zdal');
INSERT INTO egzaminy VALUES (287, '2012-09-18', 'praktyka', 13, 8, 5, 61, 'zdal');
INSERT INTO egzaminy VALUES (288, '2012-08-21', 'teoria', 12, 14, 7, 61, 'zdal');
INSERT INTO egzaminy VALUES (289, '2012-08-28', 'praktyka', 21, 14, 7, 61, 'zdal');
INSERT INTO egzaminy VALUES (290, '2006-05-09', 'teoria', 17, 7, 4, 62, 'nie zdal');
INSERT INTO egzaminy VALUES (291, '2006-05-30', 'teoria', 1, 1, 4, 62, 'zdal');
INSERT INTO egzaminy VALUES (292, '2006-06-06', 'praktyka', 10, 10, 4, 62, 'nie zdal');
INSERT INTO egzaminy VALUES (293, '2006-06-27', 'praktyka', 6, 15, 4, 62, 'zdal');
INSERT INTO egzaminy VALUES (294, '2006-05-30', 'teoria', 10, 7, 3, 62, 'zdal');
INSERT INTO egzaminy VALUES (295, '2006-06-06', 'praktyka', 20, 9, 3, 62, 'nie zdal');
INSERT INTO egzaminy VALUES (296, '2006-06-27', 'praktyka', 26, 7, 3, 62, 'nie zdal');
INSERT INTO egzaminy VALUES (297, '2006-07-18', 'praktyka', 3, 5, 3, 62, 'zdal');
INSERT INTO egzaminy VALUES (298, '2011-01-30', 'teoria', 2, 3, 4, 63, 'zdal');
INSERT INTO egzaminy VALUES (299, '2011-02-06', 'praktyka', 2, 2, 4, 63, 'nie zdal');
INSERT INTO egzaminy VALUES (300, '2011-02-27', 'praktyka', 27, 11, 4, 63, 'nie zdal');
INSERT INTO egzaminy VALUES (301, '2011-03-20', 'praktyka', 11, 8, 4, 63, 'zdal');
INSERT INTO egzaminy VALUES (302, '2015-03-04', 'teoria', 26, 5, 4, 64, 'nie stawil sie');
INSERT INTO egzaminy VALUES (303, '2015-03-25', 'teoria', 19, 11, 4, 64, 'zdal');
INSERT INTO egzaminy VALUES (304, '2015-04-01', 'praktyka', 11, 16, 4, 64, 'nie zdal');
INSERT INTO egzaminy VALUES (305, '2015-04-22', 'praktyka', 18, 6, 4, 64, 'nie zdal');
INSERT INTO egzaminy VALUES (306, '2015-05-13', 'praktyka', 28, 12, 4, 64, 'zdal');
INSERT INTO egzaminy VALUES (307, '2010-05-12', 'teoria', 9, 12, 4, 65, 'nie zdal');
INSERT INTO egzaminy VALUES (308, '2010-06-02', 'teoria', 5, 1, 4, 65, 'zdal');
INSERT INTO egzaminy VALUES (309, '2010-06-09', 'praktyka', 6, 11, 4, 65, 'nie stawil sie');
INSERT INTO egzaminy VALUES (310, '2010-06-30', 'praktyka', 8, 13, 4, 65, 'nie zdal');
INSERT INTO egzaminy VALUES (311, '2010-07-21', 'praktyka', 22, 2, 4, 65, 'zdal');
INSERT INTO egzaminy VALUES (312, '2010-08-15', 'teoria', 30, 5, 4, 66, 'zdal');
INSERT INTO egzaminy VALUES (313, '2010-08-22', 'praktyka', 24, 12, 4, 66, 'nie stawil sie');
INSERT INTO egzaminy VALUES (314, '2010-09-12', 'praktyka', 3, 8, 4, 66, 'zdal');
INSERT INTO egzaminy VALUES (315, '2010-07-08', 'teoria', 25, 11, 4, 67, 'nie zdal');
INSERT INTO egzaminy VALUES (316, '2010-07-29', 'teoria', 1, 11, 4, 67, 'zdal');
INSERT INTO egzaminy VALUES (317, '2010-08-05', 'praktyka', 20, 6, 4, 67, 'nie zdal');
INSERT INTO egzaminy VALUES (318, '2010-08-26', 'praktyka', 14, 16, 4, 67, 'zdal');
INSERT INTO egzaminy VALUES (319, '2010-06-22', 'teoria', 4, 6, 4, 68, 'zdal');
INSERT INTO egzaminy VALUES (320, '2010-06-29', 'praktyka', 14, 12, 4, 68, 'nie zdal');
INSERT INTO egzaminy VALUES (321, '2010-07-20', 'praktyka', 30, 9, 4, 68, 'zdal');
INSERT INTO egzaminy VALUES (322, '2012-02-25', 'teoria', 6, 15, 4, 69, 'nie stawil sie');
INSERT INTO egzaminy VALUES (323, '2012-03-17', 'teoria', 23, 14, 4, 69, 'zdal');
INSERT INTO egzaminy VALUES (324, '2012-03-24', 'praktyka', 3, 15, 4, 69, 'nie zdal');
INSERT INTO egzaminy VALUES (325, '2012-04-14', 'praktyka', 22, 14, 4, 69, 'nie stawil sie');
INSERT INTO egzaminy VALUES (326, '2012-05-05', 'praktyka', 6, 3, 4, 69, 'zdal');
INSERT INTO egzaminy VALUES (327, '2013-09-14', 'teoria', 16, 1, 4, 70, 'zdal');
INSERT INTO egzaminy VALUES (328, '2013-09-21', 'praktyka', 22, 12, 4, 70, 'nie zdal');
INSERT INTO egzaminy VALUES (329, '2013-10-12', 'praktyka', 29, 1, 4, 70, 'zdal');
INSERT INTO egzaminy VALUES (330, '2012-07-03', 'teoria', 4, 5, 4, 71, 'zdal');
INSERT INTO egzaminy VALUES (331, '2012-07-10', 'praktyka', 4, 16, 4, 71, 'nie zdal');
INSERT INTO egzaminy VALUES (332, '2012-07-31', 'praktyka', 4, 3, 4, 71, 'zdal');
INSERT INTO egzaminy VALUES (333, '2011-12-06', 'teoria', 23, 10, 4, 72, 'zdal');
INSERT INTO egzaminy VALUES (334, '2011-12-13', 'praktyka', 16, 11, 4, 72, 'nie zdal');
INSERT INTO egzaminy VALUES (335, '2012-01-03', 'praktyka', 25, 11, 4, 72, 'zdal');
INSERT INTO egzaminy VALUES (336, '2011-12-27', 'teoria', 3, 13, 3, 72, 'zdal');
INSERT INTO egzaminy VALUES (337, '2012-01-03', 'praktyka', 25, 3, 3, 72, 'zdal');
INSERT INTO egzaminy VALUES (338, '2012-01-17', 'teoria', 24, 16, 5, 72, 'zdal');
INSERT INTO egzaminy VALUES (339, '2012-01-24', 'praktyka', 13, 3, 5, 72, 'nie stawil sie');
INSERT INTO egzaminy VALUES (340, '2012-02-14', 'praktyka', 28, 13, 5, 72, 'zdal');
INSERT INTO egzaminy VALUES (341, '2012-02-07', 'teoria', 19, 9, 5, 72, 'nie zdal');
INSERT INTO egzaminy VALUES (342, '2012-02-28', 'teoria', 11, 1, 5, 72, 'zdal');
INSERT INTO egzaminy VALUES (343, '2012-03-06', 'praktyka', 14, 7, 5, 72, 'nie zdal');
INSERT INTO egzaminy VALUES (344, '2012-03-27', 'praktyka', 24, 15, 5, 72, 'nie zdal');
INSERT INTO egzaminy VALUES (345, '2012-04-17', 'praktyka', 20, 13, 5, 72, 'zdal');
INSERT INTO egzaminy VALUES (346, '2006-03-28', 'teoria', 21, 4, 4, 73, 'nie zdal');
INSERT INTO egzaminy VALUES (347, '2006-04-18', 'teoria', 23, 9, 4, 73, 'zdal');
INSERT INTO egzaminy VALUES (348, '2006-04-25', 'praktyka', 25, 7, 4, 73, 'nie stawil sie');
INSERT INTO egzaminy VALUES (349, '2006-05-16', 'praktyka', 8, 6, 4, 73, 'zdal');
INSERT INTO egzaminy VALUES (350, '2006-04-18', 'teoria', 5, 4, 5, 73, 'nie zdal');
INSERT INTO egzaminy VALUES (351, '2006-05-09', 'teoria', 20, 5, 5, 73, 'zdal');
INSERT INTO egzaminy VALUES (352, '2006-05-16', 'praktyka', 15, 16, 5, 73, 'nie zdal');
INSERT INTO egzaminy VALUES (353, '2006-06-06', 'praktyka', 26, 9, 5, 73, 'nie zdal');
INSERT INTO egzaminy VALUES (354, '2006-06-27', 'praktyka', 16, 10, 5, 73, 'zdal');
INSERT INTO egzaminy VALUES (355, '2012-06-02', 'teoria', 28, 3, 4, 74, 'nie zdal');
INSERT INTO egzaminy VALUES (356, '2012-06-23', 'teoria', 15, 8, 4, 74, 'zdal');
INSERT INTO egzaminy VALUES (357, '2012-06-30', 'praktyka', 19, 6, 4, 74, 'nie zdal');
INSERT INTO egzaminy VALUES (358, '2012-07-21', 'praktyka', 21, 11, 4, 74, 'nie zdal');
INSERT INTO egzaminy VALUES (359, '2012-08-11', 'praktyka', 9, 5, 4, 74, 'zdal');
INSERT INTO egzaminy VALUES (360, '2012-06-23', 'teoria', 1, 3, 5, 74, 'nie stawil sie');
INSERT INTO egzaminy VALUES (361, '2012-07-14', 'teoria', 19, 9, 5, 74, 'zdal');
INSERT INTO egzaminy VALUES (362, '2012-07-21', 'praktyka', 31, 11, 5, 74, 'nie zdal');
INSERT INTO egzaminy VALUES (363, '2012-08-11', 'praktyka', 15, 6, 5, 74, 'nie zdal');
INSERT INTO egzaminy VALUES (364, '2012-09-01', 'praktyka', 20, 14, 5, 74, 'zdal');
INSERT INTO egzaminy VALUES (365, '2006-05-01', 'teoria', 32, 13, 4, 75, 'zdal');
INSERT INTO egzaminy VALUES (366, '2006-05-08', 'praktyka', 8, 15, 4, 75, 'nie zdal');
INSERT INTO egzaminy VALUES (367, '2006-05-29', 'praktyka', 22, 11, 4, 75, 'zdal');
INSERT INTO egzaminy VALUES (368, '2005-03-09', 'teoria', 8, 3, 4, 76, 'nie stawil sie');
INSERT INTO egzaminy VALUES (369, '2005-03-30', 'teoria', 32, 1, 4, 76, 'zdal');
INSERT INTO egzaminy VALUES (370, '2005-04-06', 'praktyka', 5, 3, 4, 76, 'nie stawil sie');
INSERT INTO egzaminy VALUES (371, '2005-04-27', 'praktyka', 1, 1, 4, 76, 'nie zdal');
INSERT INTO egzaminy VALUES (372, '2005-05-18', 'praktyka', 4, 6, 4, 76, 'zdal');
INSERT INTO egzaminy VALUES (373, '2005-03-30', 'teoria', 21, 3, 1, 76, 'zdal');
INSERT INTO egzaminy VALUES (374, '2005-04-06', 'praktyka', 6, 4, 1, 76, 'nie zdal');
INSERT INTO egzaminy VALUES (375, '2005-04-27', 'praktyka', 27, 1, 1, 76, 'nie zdal');
INSERT INTO egzaminy VALUES (376, '2005-05-18', 'praktyka', 26, 15, 1, 76, 'zdal');
INSERT INTO egzaminy VALUES (377, '2008-05-27', 'teoria', 22, 12, 4, 77, 'nie zdal');
INSERT INTO egzaminy VALUES (378, '2008-06-17', 'teoria', 14, 14, 4, 77, 'zdal');
INSERT INTO egzaminy VALUES (379, '2008-06-24', 'praktyka', 26, 15, 4, 77, 'nie zdal');
INSERT INTO egzaminy VALUES (380, '2008-07-15', 'praktyka', 16, 8, 4, 77, 'nie stawil sie');
INSERT INTO egzaminy VALUES (381, '2008-08-05', 'praktyka', 2, 6, 4, 77, 'zdal');
INSERT INTO egzaminy VALUES (382, '2007-12-01', 'teoria', 7, 9, 4, 78, 'nie zdal');
INSERT INTO egzaminy VALUES (383, '2007-12-22', 'teoria', 17, 13, 4, 78, 'zdal');
INSERT INTO egzaminy VALUES (384, '2007-12-29', 'praktyka', 21, 15, 4, 78, 'nie zdal');
INSERT INTO egzaminy VALUES (385, '2008-01-19', 'praktyka', 19, 9, 4, 78, 'zdal');
INSERT INTO egzaminy VALUES (386, '2010-10-05', 'teoria', 6, 1, 4, 79, 'nie zdal');
INSERT INTO egzaminy VALUES (387, '2010-10-26', 'teoria', 29, 10, 4, 79, 'zdal');
INSERT INTO egzaminy VALUES (388, '2010-11-02', 'praktyka', 29, 6, 4, 79, 'nie stawil sie');
INSERT INTO egzaminy VALUES (389, '2010-11-23', 'praktyka', 5, 13, 4, 79, 'nie stawil sie');
INSERT INTO egzaminy VALUES (390, '2010-12-14', 'praktyka', 13, 11, 4, 79, 'zdal');
INSERT INTO egzaminy VALUES (391, '2013-01-12', 'teoria', 8, 10, 4, 80, 'nie zdal');
INSERT INTO egzaminy VALUES (392, '2013-02-02', 'teoria', 7, 9, 4, 80, 'zdal');
INSERT INTO egzaminy VALUES (393, '2013-02-09', 'praktyka', 27, 5, 4, 80, 'nie zdal');
INSERT INTO egzaminy VALUES (394, '2013-03-02', 'praktyka', 15, 5, 4, 80, 'nie zdal');
INSERT INTO egzaminy VALUES (395, '2013-03-23', 'praktyka', 6, 10, 4, 80, 'zdal');
INSERT INTO egzaminy VALUES (396, '2013-02-02', 'teoria', 30, 13, 1, 80, 'nie zdal');
INSERT INTO egzaminy VALUES (397, '2013-02-23', 'teoria', 21, 5, 1, 80, 'zdal');
INSERT INTO egzaminy VALUES (398, '2013-03-02', 'praktyka', 2, 6, 1, 80, 'zdal');
INSERT INTO egzaminy VALUES (399, '2013-02-23', 'teoria', 7, 14, 5, 80, 'nie zdal');
INSERT INTO egzaminy VALUES (400, '2013-03-16', 'teoria', 14, 13, 5, 80, 'zdal');
INSERT INTO egzaminy VALUES (401, '2013-03-23', 'praktyka', 12, 3, 5, 80, 'nie zdal');
INSERT INTO egzaminy VALUES (402, '2013-04-13', 'praktyka', 22, 2, 5, 80, 'zdal');
INSERT INTO egzaminy VALUES (403, '2009-11-14', 'teoria', 23, 15, 4, 81, 'nie stawil sie');
INSERT INTO egzaminy VALUES (404, '2009-12-05', 'teoria', 9, 5, 4, 81, 'zdal');
INSERT INTO egzaminy VALUES (405, '2009-12-12', 'praktyka', 2, 6, 4, 81, 'zdal');
INSERT INTO egzaminy VALUES (406, '2004-05-29', 'teoria', 13, 13, 4, 82, 'nie zdal');
INSERT INTO egzaminy VALUES (407, '2004-06-19', 'teoria', 7, 7, 4, 82, 'zdal');
INSERT INTO egzaminy VALUES (408, '2004-06-26', 'praktyka', 29, 2, 4, 82, 'zdal');
INSERT INTO egzaminy VALUES (409, '2005-11-10', 'teoria', 15, 14, 4, 83, 'nie zdal');
INSERT INTO egzaminy VALUES (410, '2005-12-01', 'teoria', 2, 2, 4, 83, 'zdal');
INSERT INTO egzaminy VALUES (411, '2005-12-08', 'praktyka', 20, 4, 4, 83, 'zdal');
INSERT INTO egzaminy VALUES (412, '2012-06-13', 'teoria', 11, 9, 4, 84, 'nie zdal');
INSERT INTO egzaminy VALUES (413, '2012-07-04', 'teoria', 16, 9, 4, 84, 'zdal');
INSERT INTO egzaminy VALUES (414, '2012-07-11', 'praktyka', 4, 14, 4, 84, 'nie zdal');
INSERT INTO egzaminy VALUES (415, '2012-08-01', 'praktyka', 13, 5, 4, 84, 'nie zdal');
INSERT INTO egzaminy VALUES (416, '2012-08-22', 'praktyka', 18, 9, 4, 84, 'zdal');
INSERT INTO egzaminy VALUES (417, '2012-07-04', 'teoria', 16, 16, 2, 84, 'zdal');
INSERT INTO egzaminy VALUES (418, '2012-07-11', 'praktyka', 30, 8, 2, 84, 'nie zdal');
INSERT INTO egzaminy VALUES (419, '2012-08-01', 'praktyka', 10, 2, 2, 84, 'nie zdal');
INSERT INTO egzaminy VALUES (420, '2012-08-22', 'praktyka', 9, 4, 2, 84, 'zdal');
INSERT INTO egzaminy VALUES (421, '2012-07-25', 'teoria', 27, 4, 3, 84, 'nie zdal');
INSERT INTO egzaminy VALUES (422, '2012-08-15', 'teoria', 32, 16, 3, 84, 'zdal');
INSERT INTO egzaminy VALUES (423, '2012-08-22', 'praktyka', 22, 3, 3, 84, 'nie zdal');
INSERT INTO egzaminy VALUES (424, '2012-09-12', 'praktyka', 14, 12, 3, 84, 'nie zdal');
INSERT INTO egzaminy VALUES (425, '2012-10-03', 'praktyka', 19, 15, 3, 84, 'zdal');
INSERT INTO egzaminy VALUES (426, '2006-01-06', 'teoria', 12, 2, 4, 85, 'nie zdal');
INSERT INTO egzaminy VALUES (427, '2006-01-27', 'teoria', 11, 16, 4, 85, 'zdal');
INSERT INTO egzaminy VALUES (428, '2006-02-03', 'praktyka', 26, 15, 4, 85, 'nie stawil sie');
INSERT INTO egzaminy VALUES (429, '2006-02-24', 'praktyka', 10, 15, 4, 85, 'nie zdal');
INSERT INTO egzaminy VALUES (430, '2006-03-17', 'praktyka', 2, 5, 4, 85, 'zdal');
INSERT INTO egzaminy VALUES (431, '2010-10-18', 'teoria', 17, 15, 4, 86, 'zdal');
INSERT INTO egzaminy VALUES (432, '2010-10-25', 'praktyka', 26, 8, 4, 86, 'nie zdal');
INSERT INTO egzaminy VALUES (433, '2010-11-15', 'praktyka', 19, 4, 4, 86, 'zdal');
INSERT INTO egzaminy VALUES (434, '2010-11-08', 'teoria', 9, 4, 3, 86, 'zdal');
INSERT INTO egzaminy VALUES (435, '2010-11-15', 'praktyka', 20, 13, 3, 86, 'nie zdal');
INSERT INTO egzaminy VALUES (436, '2010-12-06', 'praktyka', 30, 13, 3, 86, 'zdal');
INSERT INTO egzaminy VALUES (437, '2007-10-08', 'teoria', 8, 13, 4, 87, 'nie zdal');
INSERT INTO egzaminy VALUES (438, '2007-10-29', 'teoria', 17, 14, 4, 87, 'zdal');
INSERT INTO egzaminy VALUES (439, '2007-11-05', 'praktyka', 13, 3, 4, 87, 'nie zdal');
INSERT INTO egzaminy VALUES (440, '2007-11-26', 'praktyka', 15, 9, 4, 87, 'zdal');
INSERT INTO egzaminy VALUES (441, '2007-10-29', 'teoria', 21, 9, 6, 87, 'zdal');
INSERT INTO egzaminy VALUES (442, '2007-11-05', 'praktyka', 22, 7, 6, 87, 'nie zdal');
INSERT INTO egzaminy VALUES (443, '2007-11-26', 'praktyka', 7, 9, 6, 87, 'zdal');
INSERT INTO egzaminy VALUES (444, '2014-08-30', 'teoria', 6, 8, 4, 88, 'nie zdal');
INSERT INTO egzaminy VALUES (445, '2014-09-20', 'teoria', 13, 12, 4, 88, 'zdal');
INSERT INTO egzaminy VALUES (446, '2014-09-27', 'praktyka', 24, 13, 4, 88, 'nie zdal');
INSERT INTO egzaminy VALUES (447, '2014-10-18', 'praktyka', 5, 7, 4, 88, 'zdal');
INSERT INTO egzaminy VALUES (448, '2010-03-01', 'teoria', 18, 12, 4, 89, 'nie zdal');
INSERT INTO egzaminy VALUES (449, '2010-03-22', 'teoria', 27, 15, 4, 89, 'zdal');
INSERT INTO egzaminy VALUES (450, '2010-03-29', 'praktyka', 24, 4, 4, 89, 'nie stawil sie');
INSERT INTO egzaminy VALUES (451, '2010-04-19', 'praktyka', 31, 15, 4, 89, 'nie zdal');
INSERT INTO egzaminy VALUES (452, '2010-05-10', 'praktyka', 28, 1, 4, 89, 'zdal');
INSERT INTO egzaminy VALUES (453, '2009-05-28', 'teoria', 20, 5, 4, 90, 'zdal');
INSERT INTO egzaminy VALUES (454, '2009-06-04', 'praktyka', 9, 16, 4, 90, 'zdal');
INSERT INTO egzaminy VALUES (455, '2009-06-18', 'teoria', 27, 15, 7, 90, 'zdal');
INSERT INTO egzaminy VALUES (456, '2009-06-25', 'praktyka', 17, 11, 7, 90, 'nie zdal');
INSERT INTO egzaminy VALUES (457, '2009-07-16', 'praktyka', 19, 7, 7, 90, 'nie stawil sie');
INSERT INTO egzaminy VALUES (458, '2009-08-06', 'praktyka', 32, 16, 7, 90, 'zdal');
INSERT INTO egzaminy VALUES (459, '2008-11-27', 'teoria', 27, 14, 4, 91, 'zdal');
INSERT INTO egzaminy VALUES (460, '2008-12-04', 'praktyka', 6, 14, 4, 91, 'zdal');
INSERT INTO egzaminy VALUES (461, '2008-12-18', 'teoria', 3, 12, 3, 91, 'nie zdal');
INSERT INTO egzaminy VALUES (462, '2009-01-08', 'teoria', 5, 8, 3, 91, 'zdal');
INSERT INTO egzaminy VALUES (463, '2009-01-15', 'praktyka', 5, 8, 3, 91, 'nie zdal');
INSERT INTO egzaminy VALUES (464, '2009-02-05', 'praktyka', 28, 2, 3, 91, 'zdal');
INSERT INTO egzaminy VALUES (465, '2009-01-08', 'teoria', 25, 10, 2, 91, 'zdal');
INSERT INTO egzaminy VALUES (466, '2009-01-15', 'praktyka', 14, 3, 2, 91, 'nie zdal');
INSERT INTO egzaminy VALUES (467, '2009-02-05', 'praktyka', 21, 11, 2, 91, 'zdal');
INSERT INTO egzaminy VALUES (468, '2013-07-25', 'teoria', 25, 8, 4, 92, 'zdal');
INSERT INTO egzaminy VALUES (469, '2013-08-01', 'praktyka', 27, 6, 4, 92, 'nie zdal');
INSERT INTO egzaminy VALUES (470, '2013-08-22', 'praktyka', 21, 10, 4, 92, 'zdal');
INSERT INTO egzaminy VALUES (471, '2013-08-15', 'teoria', 15, 14, 7, 92, 'nie zdal');
INSERT INTO egzaminy VALUES (472, '2013-09-05', 'teoria', 17, 4, 7, 92, 'zdal');
INSERT INTO egzaminy VALUES (473, '2013-09-12', 'praktyka', 22, 16, 7, 92, 'nie zdal');
INSERT INTO egzaminy VALUES (474, '2013-10-03', 'praktyka', 8, 10, 7, 92, 'zdal');
INSERT INTO egzaminy VALUES (475, '2014-05-16', 'teoria', 18, 7, 4, 93, 'nie zdal');
INSERT INTO egzaminy VALUES (476, '2014-06-06', 'teoria', 10, 9, 4, 93, 'zdal');
INSERT INTO egzaminy VALUES (477, '2014-06-13', 'praktyka', 27, 10, 4, 93, 'zdal');
INSERT INTO egzaminy VALUES (478, '2014-06-06', 'teoria', 18, 2, 6, 93, 'zdal');
INSERT INTO egzaminy VALUES (479, '2014-06-13', 'praktyka', 3, 10, 6, 93, 'zdal');
INSERT INTO egzaminy VALUES (480, '2014-06-27', 'teoria', 23, 4, 6, 93, 'zdal');
INSERT INTO egzaminy VALUES (481, '2014-07-04', 'praktyka', 20, 4, 6, 93, 'nie zdal');
INSERT INTO egzaminy VALUES (482, '2014-07-25', 'praktyka', 10, 13, 6, 93, 'zdal');
INSERT INTO egzaminy VALUES (483, '2014-07-18', 'teoria', 5, 15, 1, 93, 'zdal');
INSERT INTO egzaminy VALUES (484, '2014-07-25', 'praktyka', 28, 13, 1, 93, 'nie zdal');
INSERT INTO egzaminy VALUES (485, '2014-08-15', 'praktyka', 28, 12, 1, 93, 'nie zdal');
INSERT INTO egzaminy VALUES (486, '2014-09-05', 'praktyka', 7, 15, 1, 93, 'zdal');
INSERT INTO egzaminy VALUES (487, '2006-04-23', 'teoria', 18, 15, 4, 94, 'nie zdal');
INSERT INTO egzaminy VALUES (488, '2006-05-14', 'teoria', 23, 6, 4, 94, 'zdal');
INSERT INTO egzaminy VALUES (489, '2006-05-21', 'praktyka', 27, 6, 4, 94, 'nie zdal');
INSERT INTO egzaminy VALUES (490, '2006-06-11', 'praktyka', 11, 2, 4, 94, 'zdal');
INSERT INTO egzaminy VALUES (491, '2006-05-14', 'teoria', 19, 12, 3, 94, 'nie zdal');
INSERT INTO egzaminy VALUES (492, '2006-06-04', 'teoria', 11, 15, 3, 94, 'zdal');
INSERT INTO egzaminy VALUES (493, '2006-06-11', 'praktyka', 20, 3, 3, 94, 'zdal');
INSERT INTO egzaminy VALUES (494, '2007-03-13', 'teoria', 12, 16, 4, 95, 'nie stawil sie');
INSERT INTO egzaminy VALUES (495, '2007-04-03', 'teoria', 8, 7, 4, 95, 'zdal');
INSERT INTO egzaminy VALUES (496, '2007-04-10', 'praktyka', 25, 1, 4, 95, 'nie zdal');
INSERT INTO egzaminy VALUES (497, '2007-05-01', 'praktyka', 31, 2, 4, 95, 'nie zdal');
INSERT INTO egzaminy VALUES (498, '2007-05-22', 'praktyka', 15, 10, 4, 95, 'zdal');
INSERT INTO egzaminy VALUES (499, '2014-03-03', 'teoria', 8, 10, 4, 96, 'zdal');
INSERT INTO egzaminy VALUES (500, '2014-03-10', 'praktyka', 7, 5, 4, 96, 'zdal');
INSERT INTO egzaminy VALUES (501, '2014-03-24', 'teoria', 13, 12, 6, 96, 'nie zdal');
INSERT INTO egzaminy VALUES (502, '2014-04-14', 'teoria', 29, 2, 6, 96, 'zdal');
INSERT INTO egzaminy VALUES (503, '2014-04-21', 'praktyka', 4, 8, 6, 96, 'nie stawil sie');
INSERT INTO egzaminy VALUES (504, '2014-05-12', 'praktyka', 3, 1, 6, 96, 'zdal');
INSERT INTO egzaminy VALUES (505, '2014-04-14', 'teoria', 10, 14, 3, 96, 'zdal');
INSERT INTO egzaminy VALUES (506, '2014-04-21', 'praktyka', 32, 6, 3, 96, 'zdal');
INSERT INTO egzaminy VALUES (507, '2014-05-05', 'teoria', 6, 3, 3, 96, 'nie zdal');
INSERT INTO egzaminy VALUES (508, '2014-05-26', 'teoria', 28, 8, 3, 96, 'zdal');
INSERT INTO egzaminy VALUES (509, '2014-06-02', 'praktyka', 26, 1, 3, 96, 'zdal');
INSERT INTO egzaminy VALUES (510, '2015-02-14', 'teoria', 29, 10, 4, 97, 'nie zdal');
INSERT INTO egzaminy VALUES (511, '2015-03-07', 'teoria', 28, 7, 4, 97, 'zdal');
INSERT INTO egzaminy VALUES (512, '2015-03-14', 'praktyka', 15, 13, 4, 97, 'nie zdal');
INSERT INTO egzaminy VALUES (513, '2015-04-04', 'praktyka', 15, 13, 4, 97, 'nie zdal');
INSERT INTO egzaminy VALUES (514, '2015-04-25', 'praktyka', 24, 10, 4, 97, 'zdal');
INSERT INTO egzaminy VALUES (515, '2007-05-09', 'teoria', 30, 10, 4, 98, 'nie zdal');
INSERT INTO egzaminy VALUES (516, '2007-05-30', 'teoria', 12, 15, 4, 98, 'zdal');
INSERT INTO egzaminy VALUES (517, '2007-06-06', 'praktyka', 9, 7, 4, 98, 'nie stawil sie');
INSERT INTO egzaminy VALUES (518, '2007-06-27', 'praktyka', 18, 9, 4, 98, 'nie zdal');
INSERT INTO egzaminy VALUES (519, '2007-07-18', 'praktyka', 28, 16, 4, 98, 'zdal');
INSERT INTO egzaminy VALUES (520, '2012-04-30', 'teoria', 15, 13, 4, 99, 'nie zdal');
INSERT INTO egzaminy VALUES (521, '2012-05-21', 'teoria', 3, 2, 4, 99, 'zdal');
INSERT INTO egzaminy VALUES (522, '2012-05-28', 'praktyka', 2, 6, 4, 99, 'nie zdal');
INSERT INTO egzaminy VALUES (523, '2012-06-18', 'praktyka', 4, 4, 4, 99, 'zdal');
INSERT INTO egzaminy VALUES (524, '2014-01-04', 'teoria', 16, 14, 4, 100, 'zdal');
INSERT INTO egzaminy VALUES (525, '2014-01-11', 'praktyka', 17, 2, 4, 100, 'nie zdal');
INSERT INTO egzaminy VALUES (526, '2014-02-01', 'praktyka', 11, 8, 4, 100, 'nie zdal');
INSERT INTO egzaminy VALUES (527, '2014-02-22', 'praktyka', 25, 5, 4, 100, 'zdal');
INSERT INTO prawa_jazdy VALUES ('67157/05/4285', 1, '2005-06-16', false);
INSERT INTO prawa_jazdy VALUES ('34312/05/6591', 2, '2005-08-12', true);
INSERT INTO prawa_jazdy VALUES ('05681/05/8054', 2, '2005-08-12', true);
INSERT INTO prawa_jazdy VALUES ('42034/05/4001', 2, '2005-09-02', true);
INSERT INTO prawa_jazdy VALUES ('68441/10/8703', 3, '2010-07-08', false);
INSERT INTO prawa_jazdy VALUES ('90424/10/0364', 3, '2010-09-09', false);
INSERT INTO prawa_jazdy VALUES ('98074/05/9493', 4, '2005-07-11', true);
INSERT INTO prawa_jazdy VALUES ('75615/08/4594', 5, '2008-08-16', false);
INSERT INTO prawa_jazdy VALUES ('58935/08/6359', 5, '2008-10-18', false);
INSERT INTO prawa_jazdy VALUES ('08779/08/2476', 5, '2008-10-18', false);
INSERT INTO prawa_jazdy VALUES ('64276/08/8957', 5, '2008-12-20', false);
INSERT INTO prawa_jazdy VALUES ('41430/06/9319', 6, '2006-09-26', false);
INSERT INTO prawa_jazdy VALUES ('92036/06/9242', 7, '2006-11-30', false);
INSERT INTO prawa_jazdy VALUES ('39948/09/0251', 8, '2009-12-10', true);
INSERT INTO prawa_jazdy VALUES ('50519/10/3480', 8, '2010-01-21', true);
INSERT INTO prawa_jazdy VALUES ('40681/09/1121', 8, '2009-12-31', true);
INSERT INTO prawa_jazdy VALUES ('01669/10/7186', 8, '2010-03-04', true);
INSERT INTO prawa_jazdy VALUES ('60514/08/1072', 9, '2008-03-07', false);
INSERT INTO prawa_jazdy VALUES ('39699/08/5884', 10, '2008-12-07', false);
INSERT INTO prawa_jazdy VALUES ('69076/07/7837', 11, '2007-11-19', false);
INSERT INTO prawa_jazdy VALUES ('77507/14/8051', 12, '2014-11-12', false);
INSERT INTO prawa_jazdy VALUES ('84565/07/2928', 13, '2007-09-04', false);
INSERT INTO prawa_jazdy VALUES ('31365/07/4676', 14, '2007-07-19', false);
INSERT INTO prawa_jazdy VALUES ('40476/14/4279', 15, '2014-07-31', false);
INSERT INTO prawa_jazdy VALUES ('13166/06/8108', 16, '2006-02-02', false);
INSERT INTO prawa_jazdy VALUES ('28584/07/2110', 17, '2007-12-12', false);
INSERT INTO prawa_jazdy VALUES ('13239/08/6844', 17, '2008-01-02', false);
INSERT INTO prawa_jazdy VALUES ('51965/15/2438', 18, '2015-02-14', false);
INSERT INTO prawa_jazdy VALUES ('21106/10/4551', 19, '2010-04-11', false);
INSERT INTO prawa_jazdy VALUES ('80505/08/3147', 20, '2008-05-01', false);
INSERT INTO prawa_jazdy VALUES ('72097/14/9522', 21, '2014-03-10', false);
INSERT INTO prawa_jazdy VALUES ('00858/14/8900', 21, '2014-02-17', false);
INSERT INTO prawa_jazdy VALUES ('60048/04/4587', 22, '2004-06-20', false);
INSERT INTO prawa_jazdy VALUES ('60410/12/2053', 23, '2012-08-21', false);
INSERT INTO prawa_jazdy VALUES ('75115/15/7880', 24, '2015-02-04', false);
INSERT INTO prawa_jazdy VALUES ('74656/10/3278', 25, '2010-05-23', false);
INSERT INTO prawa_jazdy VALUES ('55984/07/7722', 26, '2007-08-04', false);
INSERT INTO prawa_jazdy VALUES ('43359/10/7678', 27, '2010-02-17', false);
INSERT INTO prawa_jazdy VALUES ('98435/07/9734', 28, '2007-07-19', false);
INSERT INTO prawa_jazdy VALUES ('71319/14/7947', 29, '2014-10-29', false);
INSERT INTO prawa_jazdy VALUES ('67216/12/9745', 30, '2012-09-09', false);
INSERT INTO prawa_jazdy VALUES ('51509/12/4088', 31, '2012-02-24', false);
INSERT INTO prawa_jazdy VALUES ('37032/08/1123', 32, '2008-11-03', false);
INSERT INTO prawa_jazdy VALUES ('79574/08/7723', 32, '2008-11-03', false);
INSERT INTO prawa_jazdy VALUES ('23071/13/6010', 33, '2013-10-10', false);
INSERT INTO prawa_jazdy VALUES ('41840/05/2144', 34, '2005-11-08', false);
INSERT INTO prawa_jazdy VALUES ('62623/13/2722', 35, '2013-11-20', false);
INSERT INTO prawa_jazdy VALUES ('21835/11/2965', 36, '2011-08-28', false);
INSERT INTO prawa_jazdy VALUES ('47174/11/9376', 36, '2011-09-18', false);
INSERT INTO prawa_jazdy VALUES ('79790/13/6296', 37, '2013-02-07', false);
INSERT INTO prawa_jazdy VALUES ('91202/04/9507', 38, '2004-09-28', false);
INSERT INTO prawa_jazdy VALUES ('38248/04/0878', 38, '2004-10-19', false);
INSERT INTO prawa_jazdy VALUES ('03317/04/1293', 38, '2004-12-21', false);
INSERT INTO prawa_jazdy VALUES ('25518/06/1672', 39, '2006-01-21', true);
INSERT INTO prawa_jazdy VALUES ('21464/09/9126', 40, '2009-12-06', false);
INSERT INTO prawa_jazdy VALUES ('18425/11/7229', 41, '2011-01-31', false);
INSERT INTO prawa_jazdy VALUES ('17840/08/8076', 42, '2008-05-26', true);
INSERT INTO prawa_jazdy VALUES ('95433/08/0535', 42, '2008-05-05', true);
INSERT INTO prawa_jazdy VALUES ('16166/07/7248', 43, '2007-10-17', false);
INSERT INTO prawa_jazdy VALUES ('14279/09/7060', 44, '2009-11-27', true);
INSERT INTO prawa_jazdy VALUES ('13872/09/2466', 44, '2009-11-27', true);
INSERT INTO prawa_jazdy VALUES ('45563/13/6861', 45, '2013-09-30', false);
INSERT INTO prawa_jazdy VALUES ('45325/04/4647', 46, '2004-11-18', false);
INSERT INTO prawa_jazdy VALUES ('46016/06/5258', 47, '2006-06-29', false);
INSERT INTO prawa_jazdy VALUES ('51150/12/1987', 48, '2012-05-05', false);
INSERT INTO prawa_jazdy VALUES ('58985/15/3326', 49, '2015-05-24', true);
INSERT INTO prawa_jazdy VALUES ('14417/15/3096', 49, '2015-07-05', true);
INSERT INTO prawa_jazdy VALUES ('35608/15/6745', 49, '2015-07-05', true);
INSERT INTO prawa_jazdy VALUES ('00171/10/9550', 50, '2010-05-18', false);
INSERT INTO prawa_jazdy VALUES ('59442/14/0773', 51, '2014-03-31', false);
INSERT INTO prawa_jazdy VALUES ('35087/14/4310', 51, '2014-04-21', false);
INSERT INTO prawa_jazdy VALUES ('32569/14/8887', 51, '2014-06-02', false);
INSERT INTO prawa_jazdy VALUES ('47701/10/2003', 52, '2010-12-22', false);
INSERT INTO prawa_jazdy VALUES ('57836/14/1685', 53, '2014-07-24', false);
INSERT INTO prawa_jazdy VALUES ('45519/14/5230', 54, '2014-04-08', false);
INSERT INTO prawa_jazdy VALUES ('54897/11/0248', 55, '2011-05-28', false);
INSERT INTO prawa_jazdy VALUES ('93665/11/6343', 55, '2011-07-09', false);
INSERT INTO prawa_jazdy VALUES ('11002/04/7042', 56, '2004-09-13', false);
INSERT INTO prawa_jazdy VALUES ('21755/10/2975', 57, '2010-06-23', false);
INSERT INTO prawa_jazdy VALUES ('07986/09/2623', 58, '2009-04-29', false);
INSERT INTO prawa_jazdy VALUES ('57444/08/6522', 59, '2008-05-16', true);
INSERT INTO prawa_jazdy VALUES ('86507/08/9921', 59, '2008-04-04', true);
INSERT INTO prawa_jazdy VALUES ('34260/08/2110', 59, '2008-05-16', true);
INSERT INTO prawa_jazdy VALUES ('63981/08/9064', 59, '2008-05-16', true);
INSERT INTO prawa_jazdy VALUES ('97241/14/5585', 60, '2014-08-27', false);
INSERT INTO prawa_jazdy VALUES ('76608/14/9794', 60, '2014-08-06', false);
INSERT INTO prawa_jazdy VALUES ('72209/14/6848', 60, '2014-08-27', false);
INSERT INTO prawa_jazdy VALUES ('81941/12/1861', 61, '2012-09-06', true);
INSERT INTO prawa_jazdy VALUES ('47024/12/3938', 61, '2012-10-18', true);
INSERT INTO prawa_jazdy VALUES ('82605/12/0731', 61, '2012-09-27', true);
INSERT INTO prawa_jazdy VALUES ('14670/06/0727', 62, '2006-07-27', false);
INSERT INTO prawa_jazdy VALUES ('37084/06/8731', 62, '2006-08-17', false);
INSERT INTO prawa_jazdy VALUES ('20615/11/1536', 63, '2011-04-19', false);
INSERT INTO prawa_jazdy VALUES ('97042/15/5470', 64, '2015-06-12', true);
INSERT INTO prawa_jazdy VALUES ('97731/10/0321', 65, '2010-08-20', false);
INSERT INTO prawa_jazdy VALUES ('58601/10/2275', 66, '2010-10-12', false);
INSERT INTO prawa_jazdy VALUES ('98735/10/0177', 67, '2010-09-25', false);
INSERT INTO prawa_jazdy VALUES ('91993/10/4496', 68, '2010-08-19', false);
INSERT INTO prawa_jazdy VALUES ('29354/12/4648', 69, '2012-06-04', false);
INSERT INTO prawa_jazdy VALUES ('60988/13/2035', 70, '2013-11-11', false);
INSERT INTO prawa_jazdy VALUES ('92334/12/4316', 71, '2012-08-30', false);
INSERT INTO prawa_jazdy VALUES ('68588/12/4051', 72, '2012-02-02', true);
INSERT INTO prawa_jazdy VALUES ('72022/12/7007', 72, '2012-02-02', true);
INSERT INTO prawa_jazdy VALUES ('97379/12/1921', 72, '2012-03-15', true);
INSERT INTO prawa_jazdy VALUES ('96032/12/4803', 72, '2012-05-17', true);
INSERT INTO prawa_jazdy VALUES ('35206/06/3004', 73, '2006-06-15', false);
INSERT INTO prawa_jazdy VALUES ('71597/06/6034', 73, '2006-07-27', false);
INSERT INTO prawa_jazdy VALUES ('20001/12/7531', 74, '2012-09-10', false);
INSERT INTO prawa_jazdy VALUES ('67480/12/7674', 74, '2012-10-01', false);
INSERT INTO prawa_jazdy VALUES ('62528/06/5061', 75, '2006-06-28', false);
INSERT INTO prawa_jazdy VALUES ('97251/05/2244', 76, '2005-06-17', false);
INSERT INTO prawa_jazdy VALUES ('79533/05/5349', 76, '2005-06-17', false);
INSERT INTO prawa_jazdy VALUES ('30943/08/5235', 77, '2008-09-04', false);
INSERT INTO prawa_jazdy VALUES ('94768/08/7724', 78, '2008-02-18', false);
INSERT INTO prawa_jazdy VALUES ('41407/11/5479', 79, '2011-01-13', true);
INSERT INTO prawa_jazdy VALUES ('39341/13/0547', 80, '2013-04-22', true);
INSERT INTO prawa_jazdy VALUES ('00475/13/3965', 80, '2013-04-01', true);
INSERT INTO prawa_jazdy VALUES ('71811/13/8488', 80, '2013-05-13', true);
INSERT INTO prawa_jazdy VALUES ('21517/10/6568', 81, '2010-01-11', true);
INSERT INTO prawa_jazdy VALUES ('99328/04/1823', 82, '2004-07-26', false);
INSERT INTO prawa_jazdy VALUES ('99762/06/1965', 83, '2006-01-07', false);
INSERT INTO prawa_jazdy VALUES ('85333/12/8724', 84, '2012-09-21', false);
INSERT INTO prawa_jazdy VALUES ('73835/12/7865', 84, '2012-09-21', false);
INSERT INTO prawa_jazdy VALUES ('77741/12/0799', 84, '2012-11-02', false);
INSERT INTO prawa_jazdy VALUES ('95941/06/1931', 85, '2006-04-16', false);
INSERT INTO prawa_jazdy VALUES ('11056/10/3385', 86, '2010-12-15', false);
INSERT INTO prawa_jazdy VALUES ('35494/11/5555', 86, '2011-01-05', false);
INSERT INTO prawa_jazdy VALUES ('65864/07/6213', 87, '2007-12-26', false);
INSERT INTO prawa_jazdy VALUES ('58519/07/7999', 87, '2007-12-26', false);
INSERT INTO prawa_jazdy VALUES ('04472/14/0759', 88, '2014-11-17', true);
INSERT INTO prawa_jazdy VALUES ('08608/10/3220', 89, '2010-06-09', false);
INSERT INTO prawa_jazdy VALUES ('76383/09/6453', 90, '2009-07-04', false);
INSERT INTO prawa_jazdy VALUES ('64982/09/8176', 90, '2009-09-05', false);
INSERT INTO prawa_jazdy VALUES ('02595/09/5264', 91, '2009-01-03', true);
INSERT INTO prawa_jazdy VALUES ('53789/09/0678', 91, '2009-03-07', true);
INSERT INTO prawa_jazdy VALUES ('91361/09/2407', 91, '2009-03-07', true);
INSERT INTO prawa_jazdy VALUES ('44258/13/1973', 92, '2013-09-21', false);
INSERT INTO prawa_jazdy VALUES ('18223/13/9445', 92, '2013-11-02', false);
INSERT INTO prawa_jazdy VALUES ('00310/14/4915', 93, '2014-07-13', false);
INSERT INTO prawa_jazdy VALUES ('06396/14/0660', 93, '2014-07-13', false);
INSERT INTO prawa_jazdy VALUES ('75028/14/2347', 93, '2014-08-24', false);
INSERT INTO prawa_jazdy VALUES ('58474/14/1906', 93, '2014-10-05', false);
INSERT INTO prawa_jazdy VALUES ('39792/06/0166', 94, '2006-07-11', false);
INSERT INTO prawa_jazdy VALUES ('64538/06/8125', 94, '2006-07-11', false);
INSERT INTO prawa_jazdy VALUES ('73918/07/8817', 95, '2007-06-21', false);
INSERT INTO prawa_jazdy VALUES ('27635/14/9474', 96, '2014-04-09', false);
INSERT INTO prawa_jazdy VALUES ('99481/14/8097', 96, '2014-06-11', false);
INSERT INTO prawa_jazdy VALUES ('99684/14/4388', 96, '2014-05-21', false);
INSERT INTO prawa_jazdy VALUES ('79333/14/7413', 96, '2014-07-02', false);
INSERT INTO prawa_jazdy VALUES ('09824/15/5422', 97, '2015-05-25', false);
INSERT INTO prawa_jazdy VALUES ('96304/07/6890', 98, '2007-08-17', false);
INSERT INTO prawa_jazdy VALUES ('49322/12/6213', 99, '2012-07-18', false);
INSERT INTO prawa_jazdy VALUES ('31864/14/6311', 100, '2014-03-24', false);
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('67157/05/4285', 4, '2020-06-16');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('34312/05/6591', 4, '2020-08-12');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('05681/05/8054', 2, '2020-08-12');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('42034/05/4001', 7, '2020-09-02');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('68441/10/8703', 4, '2025-07-08');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('90424/10/0364', 3, '2025-09-09');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('98074/05/9493', 4, '2020-07-11');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('75615/08/4594', 4, '2023-08-16');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('58935/08/6359', 3, '2023-10-18');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('08779/08/2476', 3, '2023-10-18');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('64276/08/8957', 1, '2023-12-20');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('41430/06/9319', 4, '2021-09-26');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('92036/06/9242', 4, '2021-11-30');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('39948/09/0251', 4, '2024-12-10');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('50519/10/3480', 1, '2025-01-21');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('40681/09/1121', 7, '2024-12-31');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('01669/10/7186', 2, '2025-03-04');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('60514/08/1072', 4, '2023-03-07');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('39699/08/5884', 4, '2023-12-07');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('69076/07/7837', 4, '2022-11-19');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('77507/14/8051', 4, '2029-11-12');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('84565/07/2928', 4, '2022-09-04');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('31365/07/4676', 4, '2022-07-19');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('40476/14/4279', 4, '2029-07-31');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('13166/06/8108', 4, '2021-02-02');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('28584/07/2110', 4, '2022-12-12');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('13239/08/6844', 5, '2023-01-02');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('51965/15/2438', 4, '2030-02-14');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('21106/10/4551', 4, '2025-04-11');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('80505/08/3147', 4, '2023-05-01');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('72097/14/9522', 4, '2029-03-10');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('00858/14/8900', 7, '2029-02-17');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('60048/04/4587', 4, '2019-06-20');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('60410/12/2053', 4, '2027-08-21');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('75115/15/7880', 4, '2030-02-04');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('74656/10/3278', 4, '2025-05-23');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('55984/07/7722', 4, '2022-08-04');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('43359/10/7678', 4, '2025-02-17');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('98435/07/9734', 4, '2022-07-19');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('71319/14/7947', 4, '2029-10-29');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('67216/12/9745', 4, '2027-09-09');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('51509/12/4088', 4, '2027-02-24');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('37032/08/1123', 4, '2023-11-03');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('79574/08/7723', 5, '2023-11-03');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('23071/13/6010', 4, '2028-10-10');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('41840/05/2144', 4, '2020-11-08');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('62623/13/2722', 4, '2028-11-20');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('21835/11/2965', 4, '2026-08-28');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('47174/11/9376', 1, '2026-09-18');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('79790/13/6296', 4, '2028-02-07');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('91202/04/9507', 4, '2019-09-28');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('38248/04/0878', 6, '2019-10-19');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('03317/04/1293', 3, '2019-12-21');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('25518/06/1672', 4, '2021-01-21');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('21464/09/9126', 4, '2024-12-06');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('18425/11/7229', 4, '2026-01-31');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('17840/08/8076', 4, '2023-05-26');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('95433/08/0535', 8, '2023-05-05');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('16166/07/7248', 4, '2022-10-17');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('14279/09/7060', 4, '2024-11-27');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('13872/09/2466', 1, '2024-11-27');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('45563/13/6861', 4, '2028-09-30');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('45325/04/4647', 4, '2019-11-18');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('46016/06/5258', 4, '2021-06-29');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('51150/12/1987', 4, '2027-05-05');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('58985/15/3326', 4, '2030-05-24');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('14417/15/3096', 2, '2030-07-05');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('35608/15/6745', 8, '2030-07-05');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('00171/10/9550', 4, '2025-05-18');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('59442/14/0773', 4, '2029-03-31');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('35087/14/4310', 3, '2029-04-21');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('32569/14/8887', 1, '2029-06-02');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('47701/10/2003', 4, '2025-12-22');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('57836/14/1685', 4, '2029-07-24');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('45519/14/5230', 4, '2029-04-08');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('54897/11/0248', 4, '2026-05-28');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('93665/11/6343', 3, '2026-07-09');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('11002/04/7042', 4, '2019-09-13');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('21755/10/2975', 4, '2025-06-23');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('07986/09/2623', 4, '2024-04-29');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('57444/08/6522', 4, '2023-05-16');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('86507/08/9921', 3, '2023-04-04');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('34260/08/2110', 5, '2023-05-16');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('63981/08/9064', 1, '2023-05-16');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('97241/14/5585', 4, '2029-08-27');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('76608/14/9794', 3, '2029-08-06');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('72209/14/6848', 6, '2029-08-27');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('81941/12/1861', 4, '2027-09-06');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('47024/12/3938', 5, '2027-10-18');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('82605/12/0731', 7, '2027-09-27');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('14670/06/0727', 4, '2021-07-27');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('37084/06/8731', 3, '2021-08-17');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('20615/11/1536', 4, '2026-04-19');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('97042/15/5470', 4, '2030-06-12');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('97731/10/0321', 4, '2025-08-20');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('58601/10/2275', 4, '2025-10-12');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('98735/10/0177', 4, '2025-09-25');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('91993/10/4496', 4, '2025-08-19');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('29354/12/4648', 4, '2027-06-04');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('60988/13/2035', 4, '2028-11-11');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('92334/12/4316', 4, '2027-08-30');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('68588/12/4051', 4, '2027-02-02');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('72022/12/7007', 3, '2027-02-02');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('97379/12/1921', 5, '2027-03-15');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('96032/12/4803', 5, '2027-05-17');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('35206/06/3004', 4, '2021-06-15');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('71597/06/6034', 5, '2021-07-27');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('20001/12/7531', 4, '2027-09-10');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('67480/12/7674', 5, '2027-10-01');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('62528/06/5061', 4, '2021-06-28');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('97251/05/2244', 4, '2020-06-17');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('79533/05/5349', 1, '2020-06-17');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('30943/08/5235', 4, '2023-09-04');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('94768/08/7724', 4, '2023-02-18');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('41407/11/5479', 4, '2026-01-13');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('39341/13/0547', 4, '2028-04-22');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('00475/13/3965', 1, '2028-04-01');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('71811/13/8488', 5, '2028-05-13');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('21517/10/6568', 4, '2025-01-11');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('99328/04/1823', 4, '2019-07-26');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('99762/06/1965', 4, '2021-01-07');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('85333/12/8724', 4, '2027-09-21');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('73835/12/7865', 2, '2027-09-21');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('77741/12/0799', 3, '2027-11-02');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('95941/06/1931', 4, '2021-04-16');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('11056/10/3385', 4, '2025-12-15');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('35494/11/5555', 3, '2026-01-05');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('65864/07/6213', 4, '2022-12-26');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('58519/07/7999', 6, '2022-12-26');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('04472/14/0759', 4, '2029-11-17');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('08608/10/3220', 4, '2025-06-09');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('76383/09/6453', 4, '2024-07-04');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('64982/09/8176', 7, '2024-09-05');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('02595/09/5264', 4, '2024-01-03');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('53789/09/0678', 3, '2024-03-07');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('91361/09/2407', 2, '2024-03-07');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('44258/13/1973', 4, '2028-09-21');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('18223/13/9445', 7, '2028-11-02');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('00310/14/4915', 4, '2029-07-13');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('06396/14/0660', 6, '2029-07-13');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('75028/14/2347', 6, '2029-08-24');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('58474/14/1906', 1, '2029-10-05');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('39792/06/0166', 4, '2021-07-11');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('64538/06/8125', 3, '2021-07-11');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('73918/07/8817', 4, '2022-06-21');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('27635/14/9474', 4, '2029-04-09');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('99481/14/8097', 6, '2029-06-11');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('99684/14/4388', 3, '2029-05-21');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('79333/14/7413', 3, '2029-07-02');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('09824/15/5422', 4, '2030-05-25');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('96304/07/6890', 4, '2022-08-17');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('49322/12/6213', 4, '2027-07-18');
INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ('31864/14/6311', 4, '2029-03-24');
INSERT INTO pojazdy VALUES (1, 'GST4712', 'EIFFIGBH971754496', '2015-03-13', 185, 'O', 'Polska', 1087);
INSERT INTO pojazdy VALUES (2, 'SY2713Y', 'FDGJCBAG612361856', '2014-11-03', 327, 'O', 'Polska', 1981);
INSERT INTO pojazdy VALUES (3, 'PLE415V', 'IFIBHBHE763131873', '2015-07-22', 56, 'C', 'Polska', 2510);
INSERT INTO pojazdy VALUES (4, 'PWA30W6', 'AEAIDIBH756334058', '2014-09-11', 137, 'O', 'Polska', 2275);
INSERT INTO pojazdy VALUES (5, 'DBL28T6', 'JEJCGDEC653096473', '2008-01-31', 447, 'O', 'Polska', 754);
INSERT INTO pojazdy VALUES (6, 'PCT2311', 'JCGJDDFE494308415', '2014-02-04', 234, 'O', 'Polska', 1772);
INSERT INTO pojazdy VALUES (7, 'KRA925Q', 'JBFEJAEC550252648', '2009-06-23', 278, 'O', 'Polska', 2479);
INSERT INTO pojazdy VALUES (8, 'NO0L3W1', 'BEJJADFC643097472', '2010-01-18', 29, 'O', 'Polska', 684);
INSERT INTO pojazdy VALUES (9, 'PSE93H3', 'ICGGCJBH497540238', '2012-04-03', 249, 'O', 'Polska', 1914);
INSERT INTO pojazdy VALUES (10, 'ZGR1G54', 'JFJGAFID801460570', '2011-09-07', 270, 'O', 'Polska', 2385);
INSERT INTO pojazdy VALUES (11, 'PMI769P', 'ECIHJGBA527448607', '2013-05-21', 229, 'O', 'Polska', 1569);
INSERT INTO pojazdy VALUES (12, 'WWE0D8O', 'EFBHDFGA499828133', '2014-06-03', 42, 'O', 'Polska', 1417);
INSERT INTO pojazdy VALUES (13, 'LSW38WP', 'IFBJHFCH058582409', '2011-04-20', 361, 'O', 'Polska', 2075);
INSERT INTO pojazdy VALUES (14, 'NOL56Z0', 'JBBFICBC709643704', '2013-05-13', 24, 'O', 'Polska', 1039);
INSERT INTO pojazdy VALUES (15, 'SO8S08N', 'FJJAGGGD998331682', '2013-08-25', 380, 'O', 'Polska', 764);
INSERT INTO pojazdy VALUES (16, 'SBI736J', 'FEHDJIDG500058501', '2014-07-21', 488, 'C', 'Polska', 2634);
INSERT INTO pojazdy VALUES (17, 'NGI61W9', 'AEGACBDF034438688', '2012-06-03', 233, 'O', 'Polska', 1493);
INSERT INTO pojazdy VALUES (18, 'LBL08O5', 'HDEFBCGA709444021', '2012-02-07', 9, 'O', 'Polska', 1315);
INSERT INTO pojazdy VALUES (19, 'RST84V4', 'IDCCHHJB696600285', '2009-06-04', 465, 'O', 'Polska', 2211);
INSERT INTO pojazdy VALUES (20, 'NLI2U1R', 'HJIGAFEE860338469', '2016-03-11', 326, 'O', 'Polska', 942);
INSERT INTO pojazdy VALUES (21, 'TKI4R0J', 'JDCEFGFD152912427', '2016-04-26', 404, 'O', 'Polska', 947);
INSERT INTO pojazdy VALUES (22, 'EKU43F1', 'DFEBJDFJ460840152', '2014-08-16', 159, 'O', 'Polska', 1415);
INSERT INTO pojazdy VALUES (23, 'SRC42J0', 'HGDGJHED144332805', '2012-07-03', 442, 'O', 'Polska', 2486);
INSERT INTO pojazdy VALUES (24, 'GMB26Y7', 'BEADBCIE697662623', '2013-05-14', 19, 'O', 'Polska', 1732);
INSERT INTO pojazdy VALUES (25, 'CAL01AS', 'DHICHIDH095871415', '2014-01-18', 53, 'O', 'Polska', 1920);
INSERT INTO pojazdy VALUES (26, 'KTA1NRF', 'DBBHGAGH358988009', '2014-10-03', 24, 'O', 'Polska', 1039);
INSERT INTO pojazdy VALUES (27, 'SBE6U06', 'DGBHBDCC729259905', '2015-04-20', 307, 'O', 'Polska', 1202);
INSERT INTO pojazdy VALUES (28, 'LBL71PF', 'CBADAIHD825699592', '2010-02-09', 154, 'O', 'Polska', 1475);
INSERT INTO pojazdy VALUES (29, 'NGI3QV6', 'IIJAHJHC462641198', '2011-09-08', 197, 'O', 'Polska', 2190);
INSERT INTO pojazdy VALUES (30, 'CZN43NW', 'CDHGGFBA331045369', '2013-10-15', 204, 'O', 'Polska', 1455);
INSERT INTO pojazdy VALUES (31, 'CNA0D82', 'GGGGIDJD821789519', '2015-04-19', 341, 'O', 'Polska', 2309);
INSERT INTO pojazdy VALUES (32, 'PLE4515', 'IJAIGCCC298355162', '2010-08-07', 503, 'O', 'Polska', 1297);
INSERT INTO pojazdy VALUES (33, 'CRY4SFV', 'EFAEDFFH850738370', '2013-11-10', 397, 'O', 'Polska', 2104);
INSERT INTO pojazdy VALUES (34, 'TST178D', 'IGEIBFBI417233313', '2012-10-31', 380, 'O', 'Polska', 764);
INSERT INTO pojazdy VALUES (35, 'RSA3RFV', 'FBGDIBDJ946015965', '2015-06-01', 27, 'O', 'Polska', 1529);
INSERT INTO pojazdy VALUES (36, 'PKO45S3', 'AEFAJGHB526075872', '2015-12-25', 109, 'O', 'Polska', 1468);
INSERT INTO pojazdy VALUES (37, 'CSW941M', 'JDDJIHEA949721879', '2014-05-25', 102, 'O', 'Polska', 1989);
INSERT INTO pojazdy VALUES (38, 'NOG0I8B', 'FFDDAAJI614999260', '2007-04-21', 185, 'O', 'Polska', 1087);
INSERT INTO pojazdy VALUES (39, 'WWL7M6L', 'CCHJDHIF226539536', '2015-04-01', 347, 'O', 'Polska', 2205);
INSERT INTO pojazdy VALUES (40, 'BS3751H', 'HIGFIIAI357474738', '2015-07-26', 42, 'O', 'Polska', 1417);
INSERT INTO pojazdy VALUES (41, 'SW1J23L', 'IDAGFAEE401857793', '2010-12-12', 113, 'O', 'Polska', 2268);
INSERT INTO pojazdy VALUES (42, 'SBE060D', 'IEGHHBGA568316867', '2009-07-22', 425, 'O', 'Polska', 1755);
INSERT INTO pojazdy VALUES (43, 'PMI196J', 'CIDCFJHE208242720', '2014-09-05', 435, 'O', 'Polska', 753);
INSERT INTO pojazdy VALUES (44, 'DLW0456', 'FDAHDEFD882843926', '2015-11-26', 76, 'O', 'Polska', 1417);
INSERT INTO pojazdy VALUES (45, 'PLE8BPL', 'JFJEEDDE956028363', '2014-09-13', 506, 'O', 'Polska', 753);
INSERT INTO pojazdy VALUES (46, 'LZA1V8J', 'AFBAJGFA488830666', '2014-01-03', 328, 'O', 'Polska', 2429);
INSERT INTO pojazdy VALUES (47, 'KGR8GJY', 'GJCGCCGE678325600', '2016-04-05', 364, 'O', 'Polska', 1819);
INSERT INTO pojazdy VALUES (48, 'LHR6JOK', 'DFHJFBCA801417862', '2010-01-29', 245, 'O', 'Polska', 1684);
INSERT INTO pojazdy VALUES (49, 'DMI5144', 'GGCJHHHJ264522841', '2013-09-29', 213, 'O', 'Polska', 2436);
INSERT INTO pojazdy VALUES (50, 'POT593X', 'AHIGABGD209961406', '2008-02-28', 484, 'O', 'Polska', 2447);
INSERT INTO pojazdy VALUES (51, 'PGN35ZY', 'DHJDBAFF915298569', '2010-01-19', 71, 'O', 'Polska', 2273);
INSERT INTO pojazdy VALUES (52, 'WOR2YJ7', 'HFBFICCA583730306', '2015-05-04', 177, 'O', 'Polska', 1680);
INSERT INTO pojazdy VALUES (53, 'WM7687H', 'BHEFFGHD204613523', '2016-03-10', 76, 'O', 'Polska', 1417);
INSERT INTO pojazdy VALUES (54, 'SC729OL', 'HCHIBHJA671476567', '2014-01-30', 440, 'O', 'Polska', 1821);
INSERT INTO pojazdy VALUES (55, 'PCT8330', 'JEJEBIGH660013526', '2015-12-11', 115, 'O', 'Polska', 2111);
INSERT INTO pojazdy VALUES (56, 'PWA5T69', 'BHJDGGFC017905312', '2014-08-20', 89, 'O', 'Polska', 1330);
INSERT INTO pojazdy VALUES (57, 'RRS21SH', 'IDBBIJAB671309135', '2008-03-09', 69, 'O', 'Polska', 804);
INSERT INTO pojazdy VALUES (58, 'CZN6X61', 'FIIHBEEJ495278640', '2010-05-02', 316, 'O', 'Polska', 2017);
INSERT INTO pojazdy VALUES (59, 'BGR88JF', 'AGCGGEAC250756417', '2012-02-26', 80, 'O', 'Polska', 1296);
INSERT INTO pojazdy VALUES (60, 'PCT3H54', 'IIFIJDIC176943920', '2015-11-01', 416, 'O', 'Polska', 770);
INSERT INTO pojazdy VALUES (61, 'FZA4832', 'AJCBJCEF070203701', '2015-10-07', 228, 'O', 'Polska', 1811);
INSERT INTO pojazdy VALUES (62, 'ESK9SJV', 'CDABFBGI261806355', '2014-08-08', 323, 'O', 'Polska', 1103);
INSERT INTO pojazdy VALUES (63, 'RP4A447', 'IDACCFGG404703929', '2015-08-19', 67, 'O', 'Polska', 2098);
INSERT INTO pojazdy VALUES (64, 'CLI07N4', 'JDDIDFFI721749541', '2014-01-27', 466, 'O', 'Polska', 2451);
INSERT INTO pojazdy VALUES (65, 'LLB392Q', 'ICEDEEHI194094221', '2012-02-16', 254, 'O', 'Polska', 980);
INSERT INTO pojazdy VALUES (66, 'WO71083', 'ADJFFJAE750259768', '2010-05-08', 30, 'O', 'Polska', 2389);
INSERT INTO pojazdy VALUES (67, 'TPI5LKY', 'CCIBHJIH750064820', '2015-04-12', 361, 'O', 'Polska', 2075);
INSERT INTO pojazdy VALUES (68, 'LTM0WQ4', 'JGDHBEBJ943145767', '2015-06-11', 203, 'O', 'Polska', 1320);
INSERT INTO pojazdy VALUES (69, 'DTR0PDJ', 'AFEEIIFE523039734', '2012-10-30', 74, 'O', 'Polska', 952);
INSERT INTO pojazdy VALUES (70, 'ZWA2PLR', 'AFJIBHAA458706780', '2007-08-03', 503, 'O', 'Polska', 1297);
INSERT INTO pojazdy VALUES (71, 'NGI2521', 'DEEBGJJD364071299', '2008-07-09', 462, 'O', 'Polska', 2421);
INSERT INTO pojazdy VALUES (72, 'ZMY06TW', 'IFHIDBFA720210332', '2012-11-21', 345, 'O', 'Polska', 1238);
INSERT INTO pojazdy VALUES (73, 'DZL8PG6', 'IFJHEIAJ070767329', '2015-03-20', 163, 'O', 'Polska', 2449);
INSERT INTO pojazdy VALUES (74, 'GKW88G6', 'CCBBGDAA935947526', '2011-03-04', 102, 'O', 'Polska', 1989);
INSERT INTO pojazdy VALUES (75, 'CSW8JH9', 'FBBABJII606308613', '2016-05-13', 11, 'C', 'Polska', 2616);
INSERT INTO pojazdy VALUES (76, 'EL7E8N1', 'FGIGBHAI638814690', '2014-06-18', 361, 'O', 'Polska', 2075);
INSERT INTO pojazdy VALUES (77, 'WWL0P01', 'IFCJFEJH964621821', '2014-11-08', 52, 'O', 'Polska', 949);
INSERT INTO pojazdy VALUES (78, 'LLE5Q51', 'AFBDHJHB557348772', '2015-09-12', 155, 'O', 'Polska', 1867);
INSERT INTO pojazdy VALUES (79, 'WLS0JG8', 'FFECECIJ416166912', '2014-11-28', 433, 'O', 'Polska', 1628);
INSERT INTO pojazdy VALUES (80, 'WGR5097', 'ACEGGDFG927328776', '2014-03-05', 208, 'O', 'Polska', 1841);
INSERT INTO pojazdy VALUES (81, 'GSL0SK6', 'HAEIGABA931529646', '2014-08-13', 71, 'O', 'Polska', 2273);
INSERT INTO pojazdy VALUES (82, 'ERA16TZ', 'GFADGDEF774818428', '2015-03-04', 189, 'O', 'Polska', 882);
INSERT INTO pojazdy VALUES (83, 'NBA35EO', 'ADHEECFB856731687', '2014-08-23', 456, 'O', 'Polska', 719);
INSERT INTO pojazdy VALUES (84, 'DGL4B18', 'BCIFJGFB391171017', '2007-07-06', 356, 'O', 'Polska', 2282);
INSERT INTO pojazdy VALUES (85, 'DBL1J8E', 'BGJIGDFD624052831', '2011-03-01', 51, 'O', 'Polska', 935);
INSERT INTO pojazdy VALUES (86, 'FZ328G6', 'GHFDAIHB975159374', '2014-02-28', 445, 'O', 'Polska', 1362);
INSERT INTO pojazdy VALUES (87, 'DZL1933', 'GDFBHHDC348868765', '2016-04-29', 11, 'C', 'Polska', 2616);
INSERT INTO pojazdy VALUES (88, 'LRA83NU', 'CJCJDHAD170059775', '2015-01-28', 98, 'O', 'Polska', 1505);
INSERT INTO pojazdy VALUES (89, 'EPI7G2T', 'ICACFIAD247494895', '2015-08-26', 428, 'O', 'Polska', 1604);
INSERT INTO pojazdy VALUES (90, 'SMY5L6B', 'CFJGDDGG048781545', '2014-04-28', 91, 'O', 'Polska', 776);
INSERT INTO pojazdy VALUES (91, 'GND2042', 'IGABFIAC560598642', '2015-10-27', 503, 'O', 'Polska', 1297);
INSERT INTO pojazdy VALUES (92, 'RTA793U', 'EDIDAIHF749920768', '2015-11-01', 331, 'O', 'Polska', 977);
INSERT INTO pojazdy VALUES (93, 'POZ17QW', 'BABCFEFJ378818142', '2011-06-14', 403, 'C', 'Polska', 2610);
INSERT INTO pojazdy VALUES (94, 'KTA6LHM', 'FADIEFAD361729216', '2011-07-03', 364, 'O', 'Polska', 1819);
INSERT INTO pojazdy VALUES (95, 'RT5751R', 'JGJFHBDC400475035', '2014-01-01', 24, 'O', 'Polska', 1039);
INSERT INTO pojazdy VALUES (96, 'SZ3S3M3', 'HBCIJIIC014245547', '2015-04-18', 444, 'O', 'Polska', 2273);
INSERT INTO pojazdy VALUES (97, 'ZKL1N12', 'GEJHICIJ163434522', '2016-05-26', 282, 'O', 'Polska', 2172);
INSERT INTO pojazdy VALUES (98, 'TST1T84', 'HIECDIBB194226765', '2014-04-04', 441, 'O', 'Polska', 1999);
INSERT INTO pojazdy VALUES (99, 'KWI5B68', 'EHGHHADA742230197', '2015-11-03', 249, 'O', 'Polska', 1914);
INSERT INTO pojazdy VALUES (100, 'SRS193O', 'BJIHEFAB882233789', '2015-12-14', 336, 'O', 'Polska', 1770);
INSERT INTO pojazdy VALUES (101, 'NNM5ENF', 'FFGFGBAB361124486', '2014-02-23', 417, 'O', 'Polska', 720);
INSERT INTO pojazdy VALUES (102, 'CTR3O64', 'FACGAGHH511900012', '2015-09-24', 471, 'O', 'Polska', 1024);
INSERT INTO pojazdy VALUES (103, 'ZSD435R', 'AJJDGGAJ406040832', '2015-05-15', 46, 'O', 'Polska', 1662);
INSERT INTO pojazdy VALUES (104, 'OK25113', 'DDBCGJCJ809223890', '2013-11-19', 49, 'O', 'Polska', 1054);
INSERT INTO pojazdy VALUES (105, 'ERW07TI', 'ABCHGABE051367943', '2013-08-31', 343, 'O', 'Polska', 933);
INSERT INTO pojazdy VALUES (106, 'WKZ6350', 'CIFEDDHA687252014', '2013-09-07', 193, 'O', 'Polska', 1381);
INSERT INTO pojazdy VALUES (107, 'PNT48RF', 'EGIGFCCB320625167', '2013-07-22', 434, 'O', 'Polska', 1161);
INSERT INTO pojazdy VALUES (108, 'EPD0YW2', 'DJEGBHEB290114347', '2015-03-17', 136, 'C', 'Polska', 2621);
INSERT INTO pojazdy VALUES (109, 'ESI5ZOT', 'HFEGJGFE104642778', '2014-08-29', 207, 'O', 'Polska', 2043);
INSERT INTO pojazdy VALUES (110, 'SPS2CMV', 'BEAHEEEE387269802', '2012-10-06', 40, 'O', 'Polska', 869);
INSERT INTO pojazdy VALUES (111, 'KBC3J31', 'AADCHABB099637227', '2009-02-14', 294, 'O', 'Polska', 1851);
INSERT INTO pojazdy VALUES (112, 'SPS5VTZ', 'CJIJHJHB300261521', '2007-09-10', 86, 'O', 'Polska', 661);
INSERT INTO pojazdy VALUES (113, 'GPU6X14', 'IFEICIED911406168', '2013-11-19', 476, 'O', 'Polska', 1859);
INSERT INTO pojazdy VALUES (114, 'FSD7A8C', 'CAGFDJHA034312470', '2015-06-23', 487, 'O', 'Polska', 2459);
INSERT INTO pojazdy VALUES (115, 'FSL9F82', 'HGCBFHGC747819340', '2006-03-16', 256, 'C', 'Polska', 2616);
INSERT INTO pojazdy VALUES (116, 'CTR8C18', 'FIEGIEAB492217023', '2006-11-13', 135, 'O', 'Polska', 909);
INSERT INTO pojazdy VALUES (117, 'PCT95M2', 'JJJGCFIE634599270', '2013-12-05', 101, 'O', 'Polska', 1516);
INSERT INTO pojazdy VALUES (118, 'KDA954D', 'GDHIHBDF072040804', '2012-05-21', 329, 'O', 'Polska', 1062);
INSERT INTO pojazdy VALUES (119, 'BHA8K65', 'ACACHCAB564739362', '2013-04-13', 256, 'C', 'Polska', 2616);
INSERT INTO pojazdy VALUES (120, 'SZO1I4G', 'BCCBFCEI377205605', '2015-11-26', 157, 'O', 'Polska', 1143);
INSERT INTO pojazdy VALUES (121, 'NEL02A3', 'CEBCDEHD431640789', '2013-03-27', 281, 'C', 'Polska', 2567);
INSERT INTO pojazdy VALUES (122, 'ZPL0717', 'GACHEBID872146332', '2014-10-23', 231, 'O', 'Polska', 1391);
INSERT INTO pojazdy VALUES (123, 'BZA2U48', 'DEEAHGDF705112949', '2011-05-19', 508, 'O', 'Polska', 1350);
INSERT INTO pojazdy VALUES (124, 'DWR12PG', 'EIHEBBAJ066670003', '2011-09-15', 477, 'O', 'Polska', 1791);
INSERT INTO pojazdy VALUES (125, 'FNW8XKK', 'DFHEFHJD954092592', '2012-08-14', 299, 'O', 'Polska', 1336);
INSERT INTO pojazdy VALUES (126, 'RLE3937', 'HGFDFHJI223324306', '2013-06-05', 76, 'O', 'Polska', 1417);
INSERT INTO pojazdy VALUES (127, 'PKE651X', 'GJAIFBAJ118968116', '2013-10-30', 310, 'O', 'Polska', 1476);
INSERT INTO pojazdy VALUES (128, 'RKL3OCG', 'HJDEEDEF766649081', '2012-04-28', 177, 'O', 'Polska', 1680);
INSERT INTO pojazdy VALUES (129, 'EL4830U', 'FFJCADAF499858534', '2014-02-22', 119, 'O', 'Polska', 2144);
INSERT INTO pojazdy VALUES (130, 'PNT4F59', 'AAIDIDEB174034515', '2010-05-19', 102, 'O', 'Polska', 1989);
INSERT INTO pojazdy VALUES (131, 'WKZ0O2S', 'FFGEBGAI352758020', '2014-09-19', 426, 'O', 'Polska', 1468);
INSERT INTO pojazdy VALUES (132, 'LPU1QRN', 'HGDGJEFD875791839', '2012-05-17', 161, 'O', 'Polska', 1990);
INSERT INTO pojazdy VALUES (133, 'STA8F6A', 'GBHHFIGA088149534', '2016-04-29', 409, 'O', 'Polska', 1400);
INSERT INTO pojazdy VALUES (134, 'CSW3A72', 'IHDHCFAJ864754697', '2016-04-28', 476, 'O', 'Polska', 1859);
INSERT INTO pojazdy VALUES (135, 'PCT42W8', 'BGBGEECH381924858', '2015-02-21', 372, 'O', 'Polska', 1512);
INSERT INTO pojazdy VALUES (136, 'WP6E1AT', 'BCJFHBBG638878839', '2012-09-22', 125, 'O', 'Polska', 730);
INSERT INTO pojazdy VALUES (137, 'EZG6K19', 'FJCCDCDG096238911', '2012-08-04', 144, 'O', 'Polska', 1810);
INSERT INTO pojazdy VALUES (138, 'FMI8J04', 'ECBIGGAC060335300', '2014-12-13', 454, 'O', 'Polska', 2492);
INSERT INTO pojazdy VALUES (139, 'ZPL8K89', 'CFJGGHHA573009078', '2011-08-06', 394, 'O', 'Polska', 1405);
INSERT INTO pojazdy VALUES (140, 'CBY91V9', 'AIFHFIDI291856108', '2013-05-06', 439, 'O', 'Polska', 1307);
INSERT INTO pojazdy VALUES (141, 'PL519E8', 'HEJFEJIC129993897', '2015-07-03', 373, 'O', 'Polska', 2441);
INSERT INTO pojazdy VALUES (142, 'SD6Z8VO', 'DFGGAFBA619907101', '2014-03-04', 58, 'C', 'Polska', 2633);
INSERT INTO pojazdy VALUES (143, 'NKE63PC', 'ADAEJIHB065893838', '2007-12-15', 234, 'O', 'Polska', 1772);
INSERT INTO pojazdy VALUES (144, 'BZA5776', 'CGFDGFIB999568971', '2014-07-22', 327, 'O', 'Polska', 1981);
INSERT INTO pojazdy VALUES (145, 'DSR5C8E', 'EICJJHHB194371629', '2014-04-29', 317, 'O', 'Polska', 1876);
INSERT INTO pojazdy VALUES (146, 'ZST1ULT', 'GAGBCEJC772695396', '2014-08-12', 27, 'O', 'Polska', 1529);
INSERT INTO pojazdy VALUES (147, 'GSL5L0R', 'EAFIEDCH279158388', '2016-05-09', 210, 'C', 'Polska', 2627);
INSERT INTO pojazdy VALUES (148, 'WML93W5', 'DCFAEDIA570895102', '2009-02-05', 349, 'O', 'Polska', 1306);
INSERT INTO pojazdy VALUES (149, 'DPL7J65', 'AAEFJHIF883457166', '2014-11-13', 150, 'O', 'Polska', 1320);
INSERT INTO pojazdy VALUES (150, 'OKL1301', 'BBDBBEGD465182096', '2014-05-20', 139, 'O', 'Polska', 2156);
INSERT INTO pojazdy VALUES (151, 'BLM1X5V', 'FAFEGFBH812392519', '2016-01-15', 372, 'O', 'Polska', 1512);
INSERT INTO pojazdy VALUES (152, 'BZA41Y2', 'DGGFDIBF378479612', '2016-04-23', 162, 'O', 'Polska', 2463);
INSERT INTO pojazdy_kierowcy VALUES (1, 1);
INSERT INTO pojazdy_kierowcy VALUES (1, 2);
INSERT INTO pojazdy_kierowcy VALUES (2, 3);
INSERT INTO pojazdy_kierowcy VALUES (3, 4);
INSERT INTO pojazdy_kierowcy VALUES (4, 5);
INSERT INTO pojazdy_kierowcy VALUES (5, 6);
INSERT INTO pojazdy_kierowcy VALUES (5, 7);
INSERT INTO pojazdy_kierowcy VALUES (6, 8);
INSERT INTO pojazdy_kierowcy VALUES (7, 9);
INSERT INTO pojazdy_kierowcy VALUES (7, 10);
INSERT INTO pojazdy_kierowcy VALUES (8, 11);
INSERT INTO pojazdy_kierowcy VALUES (8, 12);
INSERT INTO pojazdy_kierowcy VALUES (9, 13);
INSERT INTO pojazdy_kierowcy VALUES (10, 14);
INSERT INTO pojazdy_kierowcy VALUES (11, 15);
INSERT INTO pojazdy_kierowcy VALUES (12, 16);
INSERT INTO pojazdy_kierowcy VALUES (13, 17);
INSERT INTO pojazdy_kierowcy VALUES (13, 18);
INSERT INTO pojazdy_kierowcy VALUES (14, 19);
INSERT INTO pojazdy_kierowcy VALUES (14, 20);
INSERT INTO pojazdy_kierowcy VALUES (15, 21);
INSERT INTO pojazdy_kierowcy VALUES (15, 22);
INSERT INTO pojazdy_kierowcy VALUES (16, 23);
INSERT INTO pojazdy_kierowcy VALUES (16, 24);
INSERT INTO pojazdy_kierowcy VALUES (17, 25);
INSERT INTO pojazdy_kierowcy VALUES (18, 26);
INSERT INTO pojazdy_kierowcy VALUES (18, 27);
INSERT INTO pojazdy_kierowcy VALUES (19, 28);
INSERT INTO pojazdy_kierowcy VALUES (20, 29);
INSERT INTO pojazdy_kierowcy VALUES (21, 30);
INSERT INTO pojazdy_kierowcy VALUES (21, 31);
INSERT INTO pojazdy_kierowcy VALUES (22, 32);
INSERT INTO pojazdy_kierowcy VALUES (23, 33);
INSERT INTO pojazdy_kierowcy VALUES (23, 34);
INSERT INTO pojazdy_kierowcy VALUES (24, 35);
INSERT INTO pojazdy_kierowcy VALUES (25, 36);
INSERT INTO pojazdy_kierowcy VALUES (25, 37);
INSERT INTO pojazdy_kierowcy VALUES (26, 38);
INSERT INTO pojazdy_kierowcy VALUES (26, 39);
INSERT INTO pojazdy_kierowcy VALUES (27, 40);
INSERT INTO pojazdy_kierowcy VALUES (27, 41);
INSERT INTO pojazdy_kierowcy VALUES (28, 42);
INSERT INTO pojazdy_kierowcy VALUES (29, 43);
INSERT INTO pojazdy_kierowcy VALUES (30, 44);
INSERT INTO pojazdy_kierowcy VALUES (31, 45);
INSERT INTO pojazdy_kierowcy VALUES (31, 46);
INSERT INTO pojazdy_kierowcy VALUES (32, 47);
INSERT INTO pojazdy_kierowcy VALUES (32, 48);
INSERT INTO pojazdy_kierowcy VALUES (33, 49);
INSERT INTO pojazdy_kierowcy VALUES (34, 50);
INSERT INTO pojazdy_kierowcy VALUES (34, 51);
INSERT INTO pojazdy_kierowcy VALUES (35, 52);
INSERT INTO pojazdy_kierowcy VALUES (35, 53);
INSERT INTO pojazdy_kierowcy VALUES (36, 54);
INSERT INTO pojazdy_kierowcy VALUES (36, 55);
INSERT INTO pojazdy_kierowcy VALUES (37, 56);
INSERT INTO pojazdy_kierowcy VALUES (38, 57);
INSERT INTO pojazdy_kierowcy VALUES (39, 58);
INSERT INTO pojazdy_kierowcy VALUES (40, 59);
INSERT INTO pojazdy_kierowcy VALUES (40, 60);
INSERT INTO pojazdy_kierowcy VALUES (41, 61);
INSERT INTO pojazdy_kierowcy VALUES (42, 62);
INSERT INTO pojazdy_kierowcy VALUES (42, 63);
INSERT INTO pojazdy_kierowcy VALUES (43, 64);
INSERT INTO pojazdy_kierowcy VALUES (43, 65);
INSERT INTO pojazdy_kierowcy VALUES (44, 66);
INSERT INTO pojazdy_kierowcy VALUES (45, 67);
INSERT INTO pojazdy_kierowcy VALUES (46, 68);
INSERT INTO pojazdy_kierowcy VALUES (46, 69);
INSERT INTO pojazdy_kierowcy VALUES (47, 70);
INSERT INTO pojazdy_kierowcy VALUES (47, 71);
INSERT INTO pojazdy_kierowcy VALUES (48, 72);
INSERT INTO pojazdy_kierowcy VALUES (49, 73);
INSERT INTO pojazdy_kierowcy VALUES (50, 74);
INSERT INTO pojazdy_kierowcy VALUES (51, 75);
INSERT INTO pojazdy_kierowcy VALUES (51, 76);
INSERT INTO pojazdy_kierowcy VALUES (52, 77);
INSERT INTO pojazdy_kierowcy VALUES (52, 78);
INSERT INTO pojazdy_kierowcy VALUES (53, 79);
INSERT INTO pojazdy_kierowcy VALUES (53, 80);
INSERT INTO pojazdy_kierowcy VALUES (54, 81);
INSERT INTO pojazdy_kierowcy VALUES (55, 82);
INSERT INTO pojazdy_kierowcy VALUES (55, 83);
INSERT INTO pojazdy_kierowcy VALUES (56, 84);
INSERT INTO pojazdy_kierowcy VALUES (56, 85);
INSERT INTO pojazdy_kierowcy VALUES (57, 86);
INSERT INTO pojazdy_kierowcy VALUES (58, 87);
INSERT INTO pojazdy_kierowcy VALUES (58, 88);
INSERT INTO pojazdy_kierowcy VALUES (59, 89);
INSERT INTO pojazdy_kierowcy VALUES (60, 90);
INSERT INTO pojazdy_kierowcy VALUES (60, 91);
INSERT INTO pojazdy_kierowcy VALUES (61, 92);
INSERT INTO pojazdy_kierowcy VALUES (62, 93);
INSERT INTO pojazdy_kierowcy VALUES (63, 94);
INSERT INTO pojazdy_kierowcy VALUES (63, 95);
INSERT INTO pojazdy_kierowcy VALUES (64, 96);
INSERT INTO pojazdy_kierowcy VALUES (64, 97);
INSERT INTO pojazdy_kierowcy VALUES (65, 98);
INSERT INTO pojazdy_kierowcy VALUES (66, 99);
INSERT INTO pojazdy_kierowcy VALUES (66, 100);
INSERT INTO pojazdy_kierowcy VALUES (67, 101);
INSERT INTO pojazdy_kierowcy VALUES (68, 102);
INSERT INTO pojazdy_kierowcy VALUES (68, 103);
INSERT INTO pojazdy_kierowcy VALUES (69, 104);
INSERT INTO pojazdy_kierowcy VALUES (69, 105);
INSERT INTO pojazdy_kierowcy VALUES (70, 106);
INSERT INTO pojazdy_kierowcy VALUES (71, 107);
INSERT INTO pojazdy_kierowcy VALUES (71, 108);
INSERT INTO pojazdy_kierowcy VALUES (72, 109);
INSERT INTO pojazdy_kierowcy VALUES (72, 110);
INSERT INTO pojazdy_kierowcy VALUES (73, 111);
INSERT INTO pojazdy_kierowcy VALUES (73, 112);
INSERT INTO pojazdy_kierowcy VALUES (74, 113);
INSERT INTO pojazdy_kierowcy VALUES (74, 114);
INSERT INTO pojazdy_kierowcy VALUES (75, 115);
INSERT INTO pojazdy_kierowcy VALUES (75, 116);
INSERT INTO pojazdy_kierowcy VALUES (76, 117);
INSERT INTO pojazdy_kierowcy VALUES (77, 118);
INSERT INTO pojazdy_kierowcy VALUES (78, 119);
INSERT INTO pojazdy_kierowcy VALUES (79, 120);
INSERT INTO pojazdy_kierowcy VALUES (79, 121);
INSERT INTO pojazdy_kierowcy VALUES (80, 122);
INSERT INTO pojazdy_kierowcy VALUES (81, 123);
INSERT INTO pojazdy_kierowcy VALUES (81, 124);
INSERT INTO pojazdy_kierowcy VALUES (82, 125);
INSERT INTO pojazdy_kierowcy VALUES (83, 126);
INSERT INTO pojazdy_kierowcy VALUES (84, 127);
INSERT INTO pojazdy_kierowcy VALUES (84, 128);
INSERT INTO pojazdy_kierowcy VALUES (85, 129);
INSERT INTO pojazdy_kierowcy VALUES (85, 130);
INSERT INTO pojazdy_kierowcy VALUES (86, 131);
INSERT INTO pojazdy_kierowcy VALUES (87, 132);
INSERT INTO pojazdy_kierowcy VALUES (88, 133);
INSERT INTO pojazdy_kierowcy VALUES (88, 134);
INSERT INTO pojazdy_kierowcy VALUES (89, 135);
INSERT INTO pojazdy_kierowcy VALUES (89, 136);
INSERT INTO pojazdy_kierowcy VALUES (90, 137);
INSERT INTO pojazdy_kierowcy VALUES (90, 138);
INSERT INTO pojazdy_kierowcy VALUES (91, 139);
INSERT INTO pojazdy_kierowcy VALUES (92, 140);
INSERT INTO pojazdy_kierowcy VALUES (93, 141);
INSERT INTO pojazdy_kierowcy VALUES (93, 142);
INSERT INTO pojazdy_kierowcy VALUES (94, 143);
INSERT INTO pojazdy_kierowcy VALUES (95, 144);
INSERT INTO pojazdy_kierowcy VALUES (95, 145);
INSERT INTO pojazdy_kierowcy VALUES (96, 146);
INSERT INTO pojazdy_kierowcy VALUES (97, 147);
INSERT INTO pojazdy_kierowcy VALUES (98, 148);
INSERT INTO pojazdy_kierowcy VALUES (99, 149);
INSERT INTO pojazdy_kierowcy VALUES (99, 150);
INSERT INTO pojazdy_kierowcy VALUES (100, 151);
INSERT INTO pojazdy_kierowcy VALUES (100, 152);
INSERT INTO mandaty VALUES (1, 3, 7, 32);
INSERT INTO mandaty VALUES (2, 3, 9, 26);
INSERT INTO mandaty VALUES (3, 3, 2, 20);
INSERT INTO mandaty VALUES (4, 6, 13, 27);
INSERT INTO mandaty VALUES (5, 6, 6, 24);
INSERT INTO mandaty VALUES (6, 7, 10, 14);
INSERT INTO mandaty VALUES (7, 7, 6, 4);
INSERT INTO mandaty VALUES (8, 8, 2, 23);
INSERT INTO mandaty VALUES (9, 8, 1, 27);
INSERT INTO mandaty VALUES (10, 10, 1, 7);
INSERT INTO mandaty VALUES (11, 10, 10, 3);
INSERT INTO mandaty VALUES (12, 10, 6, 8);
INSERT INTO mandaty VALUES (13, 11, 16, 6);
INSERT INTO mandaty VALUES (14, 11, 6, 19);
INSERT INTO mandaty VALUES (15, 12, 12, 20);
INSERT INTO mandaty VALUES (16, 12, 14, 3);
INSERT INTO mandaty VALUES (17, 12, 12, 8);
INSERT INTO mandaty VALUES (18, 13, 4, 29);
INSERT INTO mandaty VALUES (19, 13, 5, 27);
INSERT INTO mandaty VALUES (20, 14, 12, 14);
INSERT INTO mandaty VALUES (21, 15, 11, 3);
INSERT INTO mandaty VALUES (22, 16, 8, 30);
INSERT INTO mandaty VALUES (23, 16, 11, 24);
INSERT INTO mandaty VALUES (24, 17, 5, 31);
INSERT INTO mandaty VALUES (25, 17, 1, 20);
INSERT INTO mandaty VALUES (26, 18, 9, 2);
INSERT INTO mandaty VALUES (27, 19, 12, 4);
INSERT INTO mandaty VALUES (28, 19, 10, 19);
INSERT INTO mandaty VALUES (29, 19, 13, 20);
INSERT INTO mandaty VALUES (30, 21, 2, 29);
INSERT INTO mandaty VALUES (31, 22, 6, 21);
INSERT INTO mandaty VALUES (32, 24, 13, 5);
INSERT INTO mandaty VALUES (33, 24, 13, 13);
INSERT INTO mandaty VALUES (34, 24, 6, 12);
INSERT INTO mandaty VALUES (35, 25, 2, 25);
INSERT INTO mandaty VALUES (36, 26, 1, 20);
INSERT INTO mandaty VALUES (37, 26, 11, 17);
INSERT INTO mandaty VALUES (38, 27, 2, 30);
INSERT INTO mandaty VALUES (39, 28, 12, 30);
INSERT INTO mandaty VALUES (40, 28, 10, 6);
INSERT INTO mandaty VALUES (41, 29, 11, 14);
INSERT INTO mandaty VALUES (42, 29, 10, 27);
INSERT INTO mandaty VALUES (43, 29, 1, 9);
INSERT INTO mandaty VALUES (44, 30, 9, 9);
INSERT INTO mandaty VALUES (45, 30, 11, 11);
INSERT INTO mandaty VALUES (46, 30, 9, 10);
INSERT INTO mandaty VALUES (47, 31, 12, 1);
INSERT INTO mandaty VALUES (48, 31, 1, 6);
INSERT INTO mandaty VALUES (49, 32, 16, 15);
INSERT INTO mandaty VALUES (50, 32, 6, 9);
INSERT INTO mandaty VALUES (51, 32, 16, 16);
INSERT INTO mandaty VALUES (52, 34, 5, 3);
INSERT INTO mandaty VALUES (53, 34, 7, 26);
INSERT INTO mandaty VALUES (54, 34, 10, 3);
INSERT INTO mandaty VALUES (55, 35, 6, 2);
INSERT INTO mandaty VALUES (56, 35, 15, 2);
INSERT INTO mandaty VALUES (57, 35, 7, 1);
INSERT INTO mandaty VALUES (58, 36, 8, 5);
INSERT INTO mandaty VALUES (59, 36, 3, 7);
INSERT INTO mandaty VALUES (60, 37, 4, 15);
INSERT INTO mandaty VALUES (61, 37, 3, 11);
INSERT INTO mandaty VALUES (62, 38, 1, 28);
INSERT INTO mandaty VALUES (63, 38, 5, 10);
INSERT INTO mandaty VALUES (64, 38, 1, 28);
INSERT INTO mandaty VALUES (65, 39, 2, 22);
INSERT INTO mandaty VALUES (66, 39, 1, 18);
INSERT INTO mandaty VALUES (67, 39, 10, 12);
INSERT INTO mandaty VALUES (68, 40, 11, 26);
INSERT INTO mandaty VALUES (69, 40, 4, 29);
INSERT INTO mandaty VALUES (70, 40, 4, 20);
INSERT INTO mandaty VALUES (71, 41, 4, 4);
INSERT INTO mandaty VALUES (72, 41, 6, 24);
INSERT INTO mandaty VALUES (73, 44, 13, 27);
INSERT INTO mandaty VALUES (74, 44, 9, 26);
INSERT INTO mandaty VALUES (75, 44, 4, 20);
INSERT INTO mandaty VALUES (76, 45, 12, 19);
INSERT INTO mandaty VALUES (77, 45, 3, 22);
INSERT INTO mandaty VALUES (78, 45, 9, 10);
INSERT INTO mandaty VALUES (79, 46, 4, 20);
INSERT INTO mandaty VALUES (80, 47, 13, 20);
INSERT INTO mandaty VALUES (81, 47, 4, 4);
INSERT INTO mandaty VALUES (82, 48, 11, 11);
INSERT INTO mandaty VALUES (83, 49, 8, 18);
INSERT INTO mandaty VALUES (84, 49, 4, 11);
INSERT INTO mandaty VALUES (85, 51, 10, 16);
INSERT INTO mandaty VALUES (86, 51, 11, 19);
INSERT INTO mandaty VALUES (87, 51, 2, 27);
INSERT INTO mandaty VALUES (88, 52, 9, 10);
INSERT INTO mandaty VALUES (89, 52, 3, 19);
INSERT INTO mandaty VALUES (90, 53, 1, 17);
INSERT INTO mandaty VALUES (91, 53, 7, 14);
INSERT INTO mandaty VALUES (92, 55, 1, 13);
INSERT INTO mandaty VALUES (93, 55, 6, 19);
INSERT INTO mandaty VALUES (94, 56, 7, 22);
INSERT INTO mandaty VALUES (95, 56, 14, 28);
INSERT INTO mandaty VALUES (96, 57, 15, 12);
INSERT INTO mandaty VALUES (97, 58, 10, 21);
INSERT INTO mandaty VALUES (98, 58, 5, 8);
INSERT INTO mandaty VALUES (99, 59, 4, 26);
INSERT INTO mandaty VALUES (100, 60, 12, 26);
INSERT INTO mandaty VALUES (101, 60, 9, 17);
INSERT INTO mandaty VALUES (102, 61, 10, 27);
INSERT INTO mandaty VALUES (103, 61, 7, 10);
INSERT INTO mandaty VALUES (104, 61, 3, 7);
INSERT INTO mandaty VALUES (105, 62, 1, 10);
INSERT INTO mandaty VALUES (106, 62, 8, 14);
INSERT INTO mandaty VALUES (107, 62, 3, 5);
INSERT INTO mandaty VALUES (108, 63, 15, 17);
INSERT INTO mandaty VALUES (109, 65, 4, 4);
INSERT INTO mandaty VALUES (110, 65, 3, 11);
INSERT INTO mandaty VALUES (111, 66, 15, 6);
INSERT INTO mandaty VALUES (112, 66, 9, 16);
INSERT INTO mandaty VALUES (113, 67, 2, 30);
INSERT INTO mandaty VALUES (114, 67, 15, 2);
INSERT INTO mandaty VALUES (115, 67, 15, 26);
INSERT INTO mandaty VALUES (116, 68, 15, 4);
INSERT INTO mandaty VALUES (117, 68, 14, 19);
INSERT INTO mandaty VALUES (118, 68, 16, 1);
INSERT INTO mandaty VALUES (119, 69, 7, 3);
INSERT INTO mandaty VALUES (120, 72, 11, 28);
INSERT INTO mandaty VALUES (121, 72, 16, 29);
INSERT INTO mandaty VALUES (122, 73, 7, 22);
INSERT INTO mandaty VALUES (123, 73, 12, 28);
INSERT INTO mandaty VALUES (124, 73, 13, 3);
INSERT INTO mandaty VALUES (125, 74, 11, 22);
INSERT INTO mandaty VALUES (126, 74, 10, 18);
INSERT INTO mandaty VALUES (127, 74, 8, 26);
INSERT INTO mandaty VALUES (128, 75, 3, 25);
INSERT INTO mandaty VALUES (129, 76, 16, 27);
INSERT INTO mandaty VALUES (130, 76, 4, 19);
INSERT INTO mandaty VALUES (131, 76, 6, 11);
INSERT INTO mandaty VALUES (132, 77, 13, 8);
INSERT INTO mandaty VALUES (133, 77, 2, 3);
INSERT INTO mandaty VALUES (134, 80, 4, 4);
INSERT INTO mandaty VALUES (135, 80, 16, 8);
INSERT INTO mandaty VALUES (136, 80, 4, 17);
INSERT INTO mandaty VALUES (137, 81, 6, 3);
INSERT INTO mandaty VALUES (138, 82, 6, 1);
INSERT INTO mandaty VALUES (139, 82, 2, 32);
INSERT INTO mandaty VALUES (140, 84, 9, 3);
INSERT INTO mandaty VALUES (141, 85, 16, 22);
INSERT INTO mandaty VALUES (142, 86, 2, 25);
INSERT INTO mandaty VALUES (143, 86, 1, 12);
INSERT INTO mandaty VALUES (144, 87, 10, 27);
INSERT INTO mandaty VALUES (145, 89, 7, 26);
INSERT INTO mandaty VALUES (146, 90, 14, 28);
INSERT INTO mandaty VALUES (147, 90, 2, 15);
INSERT INTO mandaty VALUES (148, 91, 4, 16);
INSERT INTO mandaty VALUES (149, 92, 15, 6);
INSERT INTO mandaty VALUES (150, 93, 16, 14);
INSERT INTO mandaty VALUES (151, 94, 3, 28);
INSERT INTO mandaty VALUES (152, 94, 3, 9);
INSERT INTO mandaty VALUES (153, 94, 6, 25);
INSERT INTO mandaty VALUES (154, 97, 16, 9);
INSERT INTO mandaty VALUES (155, 98, 2, 25);
INSERT INTO mandaty VALUES (156, 99, 1, 10);
INSERT INTO mandaty VALUES (157, 99, 3, 9);
INSERT INTO mandaty VALUES (158, 99, 9, 20);
INSERT INTO mandaty VALUES (159, 100, 16, 17);
INSERT INTO mandaty VALUES (160, 100, 1, 2);

