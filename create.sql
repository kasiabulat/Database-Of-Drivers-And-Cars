BEGIN;
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
);

CREATE TABLE kierowcy_pojazdy(
id_kierowcy INT NOT NULL REFERENCES kierowcy,
id_pojazdu INT NOT NULL REFERENCES pojazdy,
PRIMARY KEY (id_kierowcy,id_pojazdu)
);

CREATE TABLE prawa_jazdy(
	numer_prawa_jazdy TEXT PRIMARY KEY ,
	id_właściciela INT REFERENCES kierowcy(id_kierowcy),
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
SELECT nazwa, adres, COUNT(
CASE WHEN wynik = 'zdał' THEN 1
ELSE NULL
END) AS zdało, COUNT(wynik) AS zdawało, ROUND(100 * COUNT(
CASE WHEN wynik = 'zdał' THEN 1
ELSE NULL
END)/COUNT(wynik)) AS efektywnosc
FROM ośrodki
NATURAL JOIN egzaminy
NATURAL JOIN wyniki_egzaminów
GROUP BY nazwa, adres
ORDER BY efektywnosc DESC, nazwa, adres;

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
FROM prawa_jazdy_kategorie
GROUP BY kategoria
ORDER BY ilosc DESC, kategoria;
INSERT INTO kierowcy VALUES ('1', '88112378529', 'Patrycja', 'Pawłowska', 'pawlowska.patrycja@interia.eu', '834037710', 'Marii Skłodowskiej Curie 5/7, 62-071 Wodzisław Śląski');
INSERT INTO kierowcy VALUES ('2', '91083175204', 'Blanka', 'Adamczyk', 'adamczyk.blanka@o2.pl', '788672590', 'Łódzka 5/6, 87-747 Malbork');
INSERT INTO kierowcy VALUES ('3', '86030369357', 'Oskar', 'Adamski', 'adamski.oskar@wp.pl', '814744141', 'Malinowskiego 3/3, 68-798 Włocławek');
INSERT INTO kierowcy VALUES ('4', '91071629490', 'Igor', 'Sobczak', 'sobczak.igor@interia.eu', '624110535', 'Czterech Pancernych 40/23, 47-724 Rzeszów');
INSERT INTO kierowcy VALUES ('5', '95101344937', 'Aleksander', 'Walczak', 'walczak.aleksander@gmail.com', '728865622', 'Kornela Ujejskiego 00/6, 69-050 Białystok');
INSERT INTO kierowcy VALUES ('6', '89120800358', 'Gabriel', 'Błaszczyk', 'blaszczyk.gabriel@interia.pl', '839927685', 'Biadaczowa 48/16, 13-931 Częstochowa');
INSERT INTO kierowcy VALUES ('7', '94082200849', 'Laura', 'Kaczmarek', 'kaczmarek.laura@wp.pl', '734808155', 'Lecia lecia Tysiąclecia 4/319, 19-935 Jarosław');
INSERT INTO kierowcy VALUES ('8', '91080394824', 'Nikola', 'Wiśniewska', 'wisniewska.nikola@wp.pl', '617864906', 'Jaworowa 9/77, 36-077 Skierniewice');
INSERT INTO kierowcy VALUES ('9', '90012395089', 'Paulina', 'Kaczmarczyk', 'kaczmarczyk.paulina@interia.pl', '636768692', 'Chrząstowicka 3/1, 89-804 Bytom');
INSERT INTO kierowcy VALUES ('10', '92051242274', 'Krystian', 'Sokołowski', 'sokolowski.krystian@wp.pl', '556495469', 'Synów Pułku 33/74, 05-049 Pabianice');
INSERT INTO kierowcy VALUES ('11', '87073042399', 'Bartosz', 'Krupa', 'krupa.bartosz@interia.eu', '575140273', 'Ks. Prof. Józefa Sztonyka 3/9, 74-739 Bielawa');
INSERT INTO kierowcy VALUES ('12', '86050932782', 'Katarzyna', 'Adamczyk', 'adamczyk.katarzyna@o2.pl', '647973109', 'Wieczorka 5/83, 04-046 Tychy');
INSERT INTO kierowcy VALUES ('13', '86052230727', 'Kornelia', 'Jasińska', 'jasinska.kornelia@wp.pl', '776704728', 'Na Grobli 36/759, 43-266 Bolesławiec');
INSERT INTO kierowcy VALUES ('14', '96103196270', 'Oskar', 'Wójcik', 'wojcik.oskar@wp.pl', '693720563', 'Kuszówka 6/80, 32-544 Kielce');
INSERT INTO kierowcy VALUES ('15', '90083092319', 'Dominik', 'Jaworski', 'jaworski.dominik@o2.pl', '866322085', 'Jarosława Dąbrowskiego 5/645, 49-229 Kętrzyn');
INSERT INTO kierowcy VALUES ('16', '88052294877', 'Szymon', 'Pawlak', 'pawlak.szymon@wp.pl', '695976851', 'Jerzego Kukuczki 3/538, 71-877 Olsztyn');
INSERT INTO kierowcy VALUES ('17', '90012274450', 'Patryk', 'Szczepański', 'szczepanski.patryk@interia.eu', '724455889', 'Ks. Duszy 02/26, 87-598 Świecie');
INSERT INTO kierowcy VALUES ('18', '91102729867', 'Agata', 'Szymańska', 'szymanska.agata@interia.pl', '631784564', 'Śląski Dom 2/450, 43-779 Sandomierz');
INSERT INTO kierowcy VALUES ('19', '90071634774', 'Krzysztof', 'Nowakowski', 'nowakowski.krzysztof@interia.eu', '872294573', 'Skarpowa 02/72, 77-669 Bielawa');
INSERT INTO kierowcy VALUES ('20', '93032852761', 'Gabriela', 'Mazur', 'mazur.gabriela@wp.pl', '837142493', 'Wschodnia 5/1, 66-254 Rzeszów');
INSERT INTO kierowcy VALUES ('21', '90090691000', 'Alicja', 'Szymańska', 'szymanska.alicja@interia.eu', '592326750', 'Kielecka 15/14, 91-595 Przemyśl');
INSERT INTO kierowcy VALUES ('22', '88120910306', 'Katarzyna', 'Głowacka', 'glowacka.katarzyna@gmail.com', '676368361', 'Łódzka 3/419, 38-343 Sandomierz');
INSERT INTO kierowcy VALUES ('23', '87020266193', 'Maksymilian', 'Jaworski', 'jaworski.maksymilian@interia.eu', '548837539', 'Gen. Świerczewskiego 0/78, 67-877 Jarocin');
INSERT INTO kierowcy VALUES ('24', '89032299549', 'Katarzyna', 'Dąbrowska', 'dabrowska.katarzyna@gmail.com', '527935066', 'Józefa Poniatowskiego 3/321, 80-628 Starogard Gdański');
INSERT INTO kierowcy VALUES ('25', '92042465176', 'Wiktor', 'Głowacki', 'glowacki.wiktor@o2.pl', '764040640', 'Starodworcowa 06/15, 44-679 Radom');
INSERT INTO kierowcy VALUES ('26', '93021698451', 'Alan', 'Sadowski', 'sadowski.alan@o2.pl', '811662100', 'Róży Wiatrów 4/667, 00-093 Chrzanów');
INSERT INTO kierowcy VALUES ('27', '93051719366', 'Lilianna', 'Przybylska', 'przybylska.lilianna@wp.pl', '869681881', 'Astrów 81/3, 17-954 Jasło');
INSERT INTO kierowcy VALUES ('28', '86031877079', 'Igor', 'Krawczyk', 'krawczyk.igor@wp.pl', '629991737', 'Opawska 0/144, 25-614 Biała Podlaska');
INSERT INTO kierowcy VALUES ('29', '86122961023', 'Iga', 'Nowak', 'nowak.iga@interia.eu', '548541685', 'Lazara 55/6, 80-230 Chełm');
INSERT INTO kierowcy VALUES ('30', '86041777561', 'Martyna', 'Gajewska', 'gajewska.martyna@interia.pl', '607903095', 'Kędzierzyńska 0/2, 03-380 Września');
INSERT INTO kierowcy VALUES ('31', '95061301065', 'Laura', 'Stępień', 'stepien.laura@interia.eu', '758726710', 'Ks. Czesława Klimasa 98/722, 82-472 Szczecinek');
INSERT INTO kierowcy VALUES ('32', '93081500219', 'Kamil', 'Kamiński', 'kaminski.kamil@o2.pl', '644479692', 'Orla 4/253, 92-661 Zduńska Wola');
INSERT INTO kierowcy VALUES ('33', '91020212344', 'Maja', 'Mazur', 'mazur.maja@wp.pl', '694158948', 'Sudecka 78/636, 32-442 Zgierz');
INSERT INTO kierowcy VALUES ('34', '91050225336', 'Mikołaj', 'Zając', 'zajac.mikolaj@wp.pl', '538126141', 'Etnografów 1/67, 37-661 Siedlce');
INSERT INTO kierowcy VALUES ('35', '86103014100', 'Alicja', 'Kwiatkowska', 'kwiatkowska.alicja@interia.pl', '674290713', 'Byczyńska 78/857, 53-510 Mińsk Mazowiecki');
INSERT INTO kierowcy VALUES ('36', '91082174365', 'Martyna', 'Włodarczyk', 'wlodarczyk.martyna@interia.eu', '698813476', 'Grabowska 81/800, 54-906 Grodzisk Mazowiecki');
INSERT INTO kierowcy VALUES ('37', '96120156761', 'Zuzanna', 'Szulc', 'szulc.zuzanna@wp.pl', '523143989', 'Śliwkowa 60/67, 05-102 Grudziądz');
INSERT INTO kierowcy VALUES ('38', '91041970104', 'Lena', 'Krajewska', 'krajewska.lena@interia.eu', '875649859', 'Pl. Młynów 8/917, 17-776 Rzeszów');
INSERT INTO kierowcy VALUES ('39', '95120992485', 'Michalina', 'Grabowska', 'grabowska.michalina@interia.pl', '797018143', 'Paulinki 83/9, 72-588 Dzierżoniów');
INSERT INTO kierowcy VALUES ('40', '95080798565', 'Julia', 'Gajewska', 'gajewska.julia@interia.pl', '530461476', 'Krokusów 6/350, 25-835 Stalowa Wola');
INSERT INTO kierowcy VALUES ('41', '95041301988', 'Kinga', 'Kowalczyk', 'kowalczyk.kinga@wp.pl', '592774216', 'Sławięcicka 78/90, 33-536 Ostrołęka');
INSERT INTO kierowcy VALUES ('42', '89020876420', 'Michalina', 'Andrzejewska', 'andrzejewska.michalina@gmail.com', '559527953', 'Pl. Ignacego Daszyńskiego 9/242, 59-039 Konin');
INSERT INTO kierowcy VALUES ('43', '86100656895', 'Szymon', 'Głowacki', 'glowacki.szymon@wp.pl', '874833532', 'Borowikowa 13/58, 86-052 Chojnice');
INSERT INTO kierowcy VALUES ('44', '94103074950', 'Maciej', 'Duda', 'duda.maciej@interia.eu', '759585596', 'Wilcza 2/63, 68-327 Piotrków Trybunalski');
INSERT INTO kierowcy VALUES ('45', '94030392187', 'Zuzanna', 'Zakrzewska', 'zakrzewska.zuzanna@gmail.com', '596969257', 'Granica 18/2, 42-093 Radomsko');
INSERT INTO kierowcy VALUES ('46', '90092856678', 'Oskar', 'Kaźmierczak', 'kazmierczak.oskar@gmail.com', '625400335', 'Plac Benedyktyński 52/7, 94-072 Dzierżoniów');
INSERT INTO kierowcy VALUES ('47', '96011042977', 'Olaf', 'Sobczak', 'sobczak.olaf@interia.pl', '733253882', 'Al. Turystyczna 77/75, 82-887 Tychy');
INSERT INTO kierowcy VALUES ('48', '88082373917', 'Leon', 'Stępień', 'stepien.leon@interia.eu', '836188937', 'Sobieskiego 72/3, 96-738 Łomża');
INSERT INTO kierowcy VALUES ('49', '95102766420', 'Marcelina', 'Rutkowska', 'rutkowska.marcelina@o2.pl', '720082872', 'Plażowa 8/5, 19-054 Mysłowice');
INSERT INTO kierowcy VALUES ('50', '94060663824', 'Anastazja', 'Kołodziej', 'kolodziej.anastazja@interia.eu', '507506072', 'Graniczna 8/559, 83-936 Zgierz');
INSERT INTO kierowcy VALUES ('51', '86070957358', 'Natan', 'Wysocki', 'wysocki.natan@gmail.com', '686226020', 'Dekabrystów 2/84, 56-756 Gliwice');
INSERT INTO kierowcy VALUES ('52', '96120826631', 'Franciszek', 'Mazurek', 'mazurek.franciszek@gmail.com', '616346158', 'Kędzierzyńska 20/43, 93-720 Chrzanów');
INSERT INTO kierowcy VALUES ('53', '92120913368', 'Marta', 'Ziółkowska', 'ziolkowska.marta@interia.pl', '655664835', 'Czyżyków 78/74, 69-968 Starogard Gdański');
INSERT INTO kierowcy VALUES ('54', '91122087729', 'Weronika', 'Baran', 'baran.weronika@o2.pl', '806326243', 'Św. Arnolda Janssena 44/45, 14-486 Oleśnica');
INSERT INTO kierowcy VALUES ('55', '86011586788', 'Lilianna', 'Baranowska', 'baranowska.lilianna@o2.pl', '719939897', 'Antoszka 15/8, 89-468 Chojnice');
INSERT INTO kierowcy VALUES ('56', '90032153182', 'Nikola', 'Jaworska', 'jaworska.nikola@interia.pl', '600428264', 'Tulska 62/581, 10-448 Koszalin');
INSERT INTO kierowcy VALUES ('57', '96083140205', 'Gabriela', 'Duda', 'duda.gabriela@interia.pl', '633917245', 'Podlaska 47/659, 78-453 Koszalin');
INSERT INTO kierowcy VALUES ('58', '90122026853', 'Franciszek', 'Kozłowski', 'kozlowski.franciszek@wp.pl', '641727070', 'Bolesława Leśmiana 46/906, 29-862 Gdańsk');
INSERT INTO kierowcy VALUES ('59', '93082180672', 'Oskar', 'Ziółkowski', 'ziolkowski.oskar@gmail.com', '551593663', 'Prof. Reinholda Olescha 7/8, 42-537 Żory');
INSERT INTO kierowcy VALUES ('60', '95100382570', 'Miłosz', 'Czarnecki', 'czarnecki.milosz@o2.pl', '885321963', 'Zygmunta Starego 07/7, 86-442 Ruda Śląska');
INSERT INTO kierowcy VALUES ('61', '89011233407', 'Julia', 'Malinowska', 'malinowska.julia@interia.eu', '589553532', 'Niska 76/87, 69-350 Ostrów Wielkopolski');
INSERT INTO kierowcy VALUES ('62', '87080497933', 'Maciej', 'Wysocki', 'wysocki.maciej@o2.pl', '625339214', 'Myślinka 16/559, 24-258 Gorzów Wielkopolski');
INSERT INTO kierowcy VALUES ('63', '87061733540', 'Zofia', 'Zając', 'zajac.zofia@interia.pl', '591197227', 'Kopernika 1/32, 45-436 Marki');
INSERT INTO kierowcy VALUES ('64', '96070351526', 'Martyna', 'Sikorska', 'sikorska.martyna@interia.pl', '603099920', 'Mariańska 4/385, 44-096 Żyrardów');
INSERT INTO kierowcy VALUES ('65', '92071685330', 'Franciszek', 'Olszewski', 'olszewski.franciszek@o2.pl', '579374036', 'Porcelitowa 0/7, 92-985 Żory');
INSERT INTO kierowcy VALUES ('66', '91080833677', 'Adam', 'Dudek', 'dudek.adam@interia.pl', '585772907', 'Gen. Okulickiego 88/220, 84-250 Kwidzyn');
INSERT INTO kierowcy VALUES ('67', '92022910063', 'Nina', 'Adamska', 'adamska.nina@gmail.com', '851629610', 'Stanisława Lema 21/9, 91-946 Wągrowiec');
INSERT INTO kierowcy VALUES ('68', '91091796633', 'Julian', 'Jakubowski', 'jakubowski.julian@wp.pl', '670330993', 'Gen. Dąbrowskiego 34/47, 49-270 Brzeg');
INSERT INTO kierowcy VALUES ('69', '92122769202', 'Jagoda', 'Malinowska', 'malinowska.jagoda@interia.eu', '692892387', 'Konstantego Damrota 9/5, 04-766 Sosnowiec');
INSERT INTO kierowcy VALUES ('70', '88112558671', 'Nikodem', 'Laskowski', 'laskowski.nikodem@interia.pl', '573593583', 'Lotnicza 9/4, 07-669 Brzeg');
INSERT INTO kierowcy VALUES ('71', '95042778679', 'Tomasz', 'Sokołowski', 'sokolowski.tomasz@o2.pl', '683387965', 'Wędkarska 8/51, 74-951 Nowy Sącz');
INSERT INTO kierowcy VALUES ('72', '86011730965', 'Lilianna', 'Wysocka', 'wysocka.lilianna@o2.pl', '517222456', 'Bielska 02/4, 35-332 Racibórz');
INSERT INTO kierowcy VALUES ('73', '87081107613', 'Mateusz', 'Kowalski', 'kowalski.mateusz@interia.pl', '764712098', 'Spółdzielcza 4/4, 87-540 Zamość');
INSERT INTO kierowcy VALUES ('74', '87051296361', 'Martyna', 'Brzezińska', 'brzezinska.martyna@interia.pl', '643033520', 'Elektryczna 0/15, 68-615 Dzierżoniów');
INSERT INTO kierowcy VALUES ('75', '96060930650', 'Dawid', 'Sikora', 'sikora.dawid@gmail.com', '879251155', 'Krzyżula 7/321, 58-232 Brzeg');
INSERT INTO kierowcy VALUES ('76', '93011126025', 'Natalia', 'Czarnecka', 'czarnecka.natalia@interia.eu', '863004294', 'Jakuba Kani 94/60, 40-849 Grodzisk Mazowiecki');
INSERT INTO kierowcy VALUES ('77', '89050922735', 'Dominik', 'Adamski', 'adamski.dominik@wp.pl', '792380558', 'Stefana Batorego 46/97, 23-327 Bochnia');
INSERT INTO kierowcy VALUES ('78', '88101704751', 'Mikołaj', 'Rutkowski', 'rutkowski.mikolaj@interia.pl', '805833789', 'Al. Sucha 77/3, 91-838 Radom');
INSERT INTO kierowcy VALUES ('79', '90062032235', 'Wojciech', 'Król', 'krol.wojciech@o2.pl', '694958388', 'Pokojowa 12/3, 33-861 Myszków');
INSERT INTO kierowcy VALUES ('80', '95042591216', 'Alan', 'Bąk', 'bak.alan@wp.pl', '505709874', 'Ogrodnicza 9/95, 11-049 Żory');
INSERT INTO kierowcy VALUES ('81', '95022304896', 'Natan', 'Michalak', 'michalak.natan@wp.pl', '732787671', 'Wileńska 17/985, 84-810 Wągrowiec');
INSERT INTO kierowcy VALUES ('82', '93020465753', 'Hubert', 'Malinowski', 'malinowski.hubert@gmail.com', '692973559', 'Piotra Pampucha 10/35, 89-171 Zabrze');
INSERT INTO kierowcy VALUES ('83', '86070320480', 'Zuzanna', 'Pawłowska', 'pawlowska.zuzanna@o2.pl', '718506454', 'Gen. Tadeusza Bora Komorowskiego 3/43, 52-663 Białogard');
INSERT INTO kierowcy VALUES ('84', '90090315429', 'Małgorzata', 'Grabowska', 'grabowska.malgorzata@interia.eu', '673432677', 'Jagielnicka 96/963, 04-343 Nowy Targ');
INSERT INTO kierowcy VALUES ('85', '93072078938', 'Adrian', 'Nowak', 'nowak.adrian@interia.pl', '721964876', 'Pl. Konstytucji III Maja 9/7, 52-238 Bielsko-Biała');
INSERT INTO kierowcy VALUES ('86', '91091662060', 'Lilianna', 'Cieślak', 'cieslak.lilianna@gmail.com', '709843995', 'Teatralna 01/10, 41-543 Świdnik');
INSERT INTO kierowcy VALUES ('87', '89103092363', 'Pola', 'Borowska', 'borowska.pola@interia.eu', '656209561', 'Cypriana Kamila Norwida 4/3, 11-490 Pruszcz Gdański');
INSERT INTO kierowcy VALUES ('88', '96111374828', 'Nadia', 'Kowalczyk', 'kowalczyk.nadia@interia.pl', '514735263', 'Gruntowa 6/5, 66-854 Wodzisław Śląski');
INSERT INTO kierowcy VALUES ('89', '94082558980', 'Jagoda', 'Kucharska', 'kucharska.jagoda@wp.pl', '840387964', 'Pusta 6/65, 86-950 Piła');
INSERT INTO kierowcy VALUES ('90', '92070975643', 'Natalia', 'Laskowska', 'laskowska.natalia@gmail.com', '834527823', 'Etnografów 2/7, 01-695 Kwidzyn');
INSERT INTO kierowcy VALUES ('91', '86010327733', 'Stanisław', 'Cieślak', 'cieslak.stanislaw@interia.eu', '698633491', 'Gwarków 3/187, 90-964 Pruszków');
INSERT INTO kierowcy VALUES ('92', '95010610002', 'Weronika', 'Dąbrowska', 'dabrowska.weronika@interia.eu', '812747436', 'Brzeska 25/2, 99-611 Giżycko');
INSERT INTO kierowcy VALUES ('93', '87020703425', 'Hanna', 'Sobczak', 'sobczak.hanna@interia.eu', '667651785', 'Andersa 26/54, 63-868 Iława');
INSERT INTO kierowcy VALUES ('94', '91061400377', 'Bartłomiej', 'Wróbel', 'wrobel.bartlomiej@interia.pl', '826662557', 'Równa 5/4, 99-021 Częstochowa');
INSERT INTO kierowcy VALUES ('95', '88053160654', 'Ignacy', 'Adamski', 'adamski.ignacy@interia.pl', '518788930', 'Jadwigi 69/191, 21-391 Łowicz');
INSERT INTO kierowcy VALUES ('96', '92100213718', 'Krzysztof', 'Jaworski', 'jaworski.krzysztof@interia.pl', '808426806', 'Pl. Katedralny 9/4, 13-353 Przemyśl');
INSERT INTO kierowcy VALUES ('97', '88012109058', 'Tymon', 'Bąk', 'bak.tymon@interia.eu', '713046851', 'Lawendowa 5/59, 02-626 Bytom');
INSERT INTO kierowcy VALUES ('98', '90070774248', 'Lena', 'Dąbrowska', 'dabrowska.lena@gmail.com', '655743578', 'Ks. Piotra Ściegiennego 3/9, 10-926 Mysłowice');
INSERT INTO kierowcy VALUES ('99', '96041975401', 'Jagoda', 'Zakrzewska', 'zakrzewska.jagoda@gmail.com', '538052456', 'Wysocka 7/595, 51-863 Augustów');
INSERT INTO kierowcy VALUES ('100', '89041942685', 'Helena', 'Wiśniewska', 'wisniewska.helena@wp.pl', '628154874', 'Mostowa 9/56, 50-805 Brzeg');
INSERT INTO egzaminatorzy VALUES (1, 'Bartosz', 'Kozłowski');
INSERT INTO egzaminatorzy VALUES (2, 'Nadia', 'Pawlak');
INSERT INTO egzaminatorzy VALUES (3, 'Iga', 'Szczepańska');
INSERT INTO egzaminatorzy VALUES (4, 'Natan', 'Bąk');
INSERT INTO egzaminatorzy VALUES (5, 'Maria', 'Czerwińska');
INSERT INTO egzaminatorzy VALUES (6, 'Natalia', 'Kucharska');
INSERT INTO egzaminatorzy VALUES (7, 'Piotr', 'Walczak');
INSERT INTO egzaminatorzy VALUES (8, 'Gabriel', 'Górski');
INSERT INTO egzaminatorzy VALUES (9, 'Bartosz', 'Makowski');
INSERT INTO egzaminatorzy VALUES (10, 'Karol', 'Duda');
INSERT INTO egzaminatorzy VALUES (11, 'Tomasz', 'Chmielewski');
INSERT INTO egzaminatorzy VALUES (12, 'Aleksander', 'Marciniak');
INSERT INTO egzaminatorzy VALUES (13, 'Julia', 'Nowakowska');
INSERT INTO egzaminatorzy VALUES (14, 'Bartosz', 'Zalewski');
INSERT INTO egzaminatorzy VALUES (15, 'Oliwier', 'Marciniak');
INSERT INTO egzaminatorzy VALUES (16, 'Leon', 'Marciniak');
INSERT INTO egzaminatorzy VALUES (17, 'Franciszek', 'Jankowski');
INSERT INTO egzaminatorzy VALUES (18, 'Krystian', 'Wasilewski');
INSERT INTO egzaminatorzy VALUES (19, 'Tymoteusz', 'Kamiński');
INSERT INTO egzaminatorzy VALUES (20, 'Julia', 'Krawczyk');
INSERT INTO egzaminatorzy VALUES (21, 'Amelia', 'Stępień');
INSERT INTO egzaminatorzy VALUES (22, 'Barbara', 'Kowalczyk');
INSERT INTO egzaminatorzy VALUES (23, 'Krzysztof', 'Cieślak');
INSERT INTO egzaminatorzy VALUES (24, 'Joanna', 'Wojciechowska');
INSERT INTO egzaminatorzy VALUES (25, 'Bartosz', 'Lewandowski');
INSERT INTO egzaminatorzy VALUES (26, 'Aleksandra', 'Makowska');
INSERT INTO egzaminatorzy VALUES (27, 'Alan', 'Michalski');
INSERT INTO egzaminatorzy VALUES (28, 'Marcel', 'Nowak');
INSERT INTO egzaminatorzy VALUES (29, 'Dawid', 'Kubiak');
INSERT INTO egzaminatorzy VALUES (30, 'Wiktor', 'Wróbel');
INSERT INTO egzaminatorzy VALUES (31, 'Mikołaj', 'Woźniak');
INSERT INTO egzaminatorzy VALUES (32, 'Klaudia', 'Wieczorek');
INSERT INTO ośrodki VALUES (1, 'Wojewódzki Ośrodek Ruchu Drogowego w Katowicach', 'ul. Francuska 78, 40-507 Katowice');
INSERT INTO ośrodki VALUES (2, 'Wojewódzki Ośrodek Ruchu Drogowego w Poznaniu', 'ul. Wilczak 53, 61-623 Poznań');
INSERT INTO ośrodki VALUES (3, 'Wojewódzki Ośrodek Ruchu Drogowego w Pile', 'ul. Lotnicza 6, 64-920 Piła');
INSERT INTO ośrodki VALUES (4, 'Wojewódzki Ośrodek Ruchu Drogowego w Elblągu', 'ul. Skrzydlata 1, 82-300 Elbląg');
INSERT INTO ośrodki VALUES (5, 'Wojewódzki Ośrodek Ruchu Drogowego w Rzeszowie', 'Al. Wyzwolenia 4, 35-501 Rzeszów');
INSERT INTO ośrodki VALUES (6, 'Wojewódzki Ośrodek Ruchu Drogowego w Kielcach', ' ul. Domaszowska 141B, 25-420 Kielce');
INSERT INTO ośrodki VALUES (7, 'Wojewódzki Ośrodek Ruchu Drogowego w Zamościu', 'ul. Droga Męczenników Rotundy 2, 22-400 Zamość');
INSERT INTO ośrodki VALUES (8, 'Wojewódzki Ośrodek Ruchu Drogowego w Słupsku', 'ul. Mierosławskiego 10, 76-200 Słupsk');
INSERT INTO ośrodki VALUES (9, 'Wojewódzki Ośrodek Ruchu Drogowego w Chełmie', 'ul. Bieławin 2a, 22-100 Chełm');
INSERT INTO ośrodki VALUES (10, 'Wojewódzki Ośrodek Ruchu Drogowego w Gorzowie Wielkopolskim', 'ul. Podmiejska 18, 66-400 Gorzów Wlkp.');
INSERT INTO ośrodki VALUES (11, 'Wojewódzki Ośrodek Ruchu Drogowego w Opolu', 'ul. Oleska 127, 45-233 Opole');
INSERT INTO ośrodki VALUES (12, 'Wojewódzki Ośrodek Ruchu Drogowego - Regionalne Centrum Bezpieczeństwa Ruchu Drogowego w Olsztynie', 'ul. Towarowa 17, 10-416 Olsztyn');
INSERT INTO ośrodki VALUES (13, 'Wojewódzki Ośrodek Ruchu Drogowego w Tarnobrzegu', 'ul. Sikorskiego 86 A, 39-400 Tarnobrzeg');
INSERT INTO ośrodki VALUES (14, 'Małopolski Ośrodek Ruchu Drogowego w Tarnowie', 'ul. Okrężna 2F, 33-104 Tarnów');
INSERT INTO ośrodki VALUES (15, 'Wojewódzki Ośrodek Ruchu Drogowego w Szczecinie', 'ul. Maksymiliana Golisza 10B, 71-682 Szczecin');
INSERT INTO ośrodki VALUES (16, 'Wojewódzki Ośrodek Ruchu Drogowego w Zielonej Górze', 'ul. Nowa 4b, 65-339 Zielona Góra');
INSERT INTO mandaty_wystawiający VALUES (1, 'Marcelina', 'Zawadzka');
INSERT INTO mandaty_wystawiający VALUES (2, 'Maria', 'Baran');
INSERT INTO mandaty_wystawiający VALUES (3, 'Maksymilian', 'Gajewski');
INSERT INTO mandaty_wystawiający VALUES (4, 'Magdalena', 'Woźniak');
INSERT INTO mandaty_wystawiający VALUES (5, 'Dominik', 'Sawicki');
INSERT INTO mandaty_wystawiający VALUES (6, 'Pola', 'Kaczmarek');
INSERT INTO mandaty_wystawiający VALUES (7, 'Jan', 'Pawlak');
INSERT INTO mandaty_wystawiający VALUES (8, 'Iga', 'Czerwińska');
INSERT INTO mandaty_wystawiający VALUES (9, 'Adam', 'Zając');
INSERT INTO mandaty_wystawiający VALUES (10, 'Iga', 'Stępień');
INSERT INTO mandaty_wystawiający VALUES (11, 'Antoni', 'Grabowski');
INSERT INTO mandaty_wystawiający VALUES (12, 'Antoni', 'Kozłowski');
INSERT INTO mandaty_wystawiający VALUES (13, 'Maja', 'Zawadzka');
INSERT INTO mandaty_wystawiający VALUES (14, 'Marcelina', 'Zając');
INSERT INTO mandaty_wystawiający VALUES (15, 'Maciej', 'Kowalczyk');
INSERT INTO mandaty_wystawiający VALUES (16, 'Gabriel', 'Kowalczyk');
INSERT INTO wykroczenia VALUES (1, 'Zatrzymanie lub postój pojazdu na autostradzie lub drodze ekspresowej w innych miejscach niż wyznaczone w tym celu', 300.0, 1);
INSERT INTO wykroczenia VALUES (2, 'Niezatrzymanie pojazdu w celu umożliwienia przejścia przez jezdnię osobie niepełnosprawnej, używającej specjalnego znaku lub osobie o widocznej ograniczonej sprawności ruchowej', 350.0, 10);
INSERT INTO wykroczenia VALUES (3, 'Zatrzymywanie pojazdu na jezdni wzdłuż linii ciągłej oraz w pobliżu jej punktów krańcowych, jeżeli kierujący pojazdami wielośladowymi są zmuszeni do najeżdżania na tę linię', 100.0, 1);
INSERT INTO wykroczenia VALUES (4, 'Holowanie pojazdu, w którym znajduje się kierujący niemający wymaganych uprawnień do kierowania tym pojazdem', 250.0, 0);
INSERT INTO wykroczenia VALUES (5, 'Używanie „szperacza” podczas jazdy', 100.0, 0);
INSERT INTO wykroczenia VALUES (6, 'Zatrzymywanie pojazdu na przejściu dla pieszych lub na przejeździe dla rowerzystów oraz w odległości mniejszej niż 10 m przed tym przejściem lub przejazdem, a na drodze dwukierunkowej o dwóch pasach ruchu – także za nimi', 200.0, 1);
INSERT INTO wykroczenia VALUES (7, 'Zatrzymywanie pojazdu na drodze dla rowerów, pasie ruchu dla rowerów lub w śluzie rowerowej, z wyjątkiem roweru', 100.0, 1);
INSERT INTO wykroczenia VALUES (8, 'Przekroczenie dopuszczalnej prędkości o 51 km/h i więcej', 500.0, 10);
INSERT INTO wykroczenia VALUES (9, 'Naruszenie zakazu wjeżdżania na przejazd jeśli po jego drugiej stronie nie ma miejsca do kontynuowania jazdy', 300.0, 4);
INSERT INTO wykroczenia VALUES (10, 'Naruszenie przez kierującego pojazdem innym niż silnikowy zakazu wyprzedzania innych pojazdów w czasie jazdy w warunkach zmniejszonej przejrzystości powietrza oraz obowiązku korzystania z pobocza drogi, a jeżeli nie jest to możliwe – to jazdy jak najbliżej krawędzi jezdni', 100.0, 2);
INSERT INTO wykroczenia VALUES (11, 'Nieustąpienie przez kierującego pojazdem, który skręca w drogę poprzeczną, pierwszeństwa rowerzyście jadącemu na wprost po jezdni, pasie ruchu dla rowerów, drodze dla rowerów lub innej części drogi, którą zamierza opuścić', 350.0, 6);
INSERT INTO wykroczenia VALUES (12, 'Niesygnalizowanie lub niewłaściwe sygnalizowanie postoju pojazdu silnikowego z powodu uszkodzenia lub wypadku na autostradzie lub drodze ekspresowej', 300.0, 0);
INSERT INTO wykroczenia VALUES (13, 'Naruszenie zakazu wyprzedzania na skrzyżowaniach', 300.0, 5);
INSERT INTO wykroczenia VALUES (14, 'Utrudnianie ruchu podczas cofania', 100.0, 4);
INSERT INTO wykroczenia VALUES (15, 'Naruszenie przez kierującego warunków holowania - niezachowanie właściwej odległości między pojazdami holowanym a holującym', 100.0, 0);
INSERT INTO wykroczenia VALUES (16, 'Cofanie na autostradzie lub drodze ekspresowej', 300.0, 5);
INSERT INTO wykroczenia VALUES (17, 'Zatrzymywanie pojazdu na pasie między jezdniami', 100.0, 1);
INSERT INTO wykroczenia VALUES (18, 'Nadużywanie sygnałów dźwiękowych lub świetlnych', 100.0, 0);
INSERT INTO wykroczenia VALUES (19, 'Zatrzymywanie pojazdu w odległości mniejszej niż 10 m od przedniej strony znaku lub sygnału drogowego, jeżeli pojazd je zasłania', 100.0, 1);
INSERT INTO wykroczenia VALUES (20, 'Naruszenie warunków dopuszczalności używania przednich świateł przeciwmgłowych', 100.0, 2);
INSERT INTO wykroczenia VALUES (21, 'Kierowanie pojazdem przez osobę nieposiadającą przy sobie wymaganych dokumentów', 50.0, 0);
INSERT INTO wykroczenia VALUES (22, 'Kierowanie motorowerem lub czterokołowcem lekkim przez osobę niemającą do tego uprawnienia', 200.0, 0);
INSERT INTO wykroczenia VALUES (23, 'Brak sygnalizowania lub niewłaściwe sygnalizowanie postoju pojazdu z powodu uszkodzenia lub wypadku', 150.0, 1);
INSERT INTO wykroczenia VALUES (24, 'Nieużywanie wymaganego oświetlenia podczas zatrzymania lub postoju w warunkach niedostatecznej widoczności', 200.0, 3);
INSERT INTO wykroczenia VALUES (25, 'Naruszenie przez kierującego warunków holowania - brak oznaczenia lub niewłaściwe oznaczenie pojazdu holowanego', 150.0, 0);
INSERT INTO wykroczenia VALUES (26, 'Uniemożliwienie włączenia się do ruchu autobusowi (trolejbusowi) sygnalizującemu zamiar zmiany pasa ruchu lub wjechania z zatoki na jezdnię z oznaczonego przystanku na obszarze zabudowanym', 200.0, 0);
INSERT INTO wykroczenia VALUES (27, 'Omijanie pojazdu, który jechał w tym samym kierunku, lecz zatrzymał się w celu ustąpienia pierwszeństwa pieszemu', 500.0, 10);
INSERT INTO wykroczenia VALUES (28, 'Naruszenie zakazu postoju w miejscach utrudniających wjazd lub wyjazd', 100.0, 1);
INSERT INTO wykroczenia VALUES (29, 'Naruszenie przez kierującego warunków holowania - niewłączanie w pojeździe holującym świateł mijania', 100.0, 0);
INSERT INTO wykroczenia VALUES (30, 'Jazda wzdłuż po chodniku lub przejściu dla pieszych pojazdem silnikowym', 250.0, 0);
INSERT INTO wykroczenia VALUES (31, 'Zatrzymanie lub postój pojazdu w warunkach, w których nie jest on z dostatecznej odległości widoczny dla innych kierujących lub powoduje utrudnienie ruchu', 200.0, 1);
INSERT INTO wykroczenia VALUES (32, 'Holowanie pojazdem z przyczepą (naczepą)', 250.0, 0);
INSERT INTO mandaty VALUES (1, 2, 7, 22);
INSERT INTO mandaty VALUES (2, 2, 16, 29);
INSERT INTO mandaty VALUES (3, 3, 4, 24);
INSERT INTO mandaty VALUES (4, 7, 1, 17);
INSERT INTO mandaty VALUES (5, 7, 11, 28);
INSERT INTO mandaty VALUES (6, 7, 2, 30);
INSERT INTO mandaty VALUES (7, 9, 1, 11);
INSERT INTO mandaty VALUES (8, 9, 12, 20);
INSERT INTO mandaty VALUES (9, 9, 10, 9);
INSERT INTO mandaty VALUES (10, 10, 13, 22);
INSERT INTO mandaty VALUES (11, 12, 1, 8);
INSERT INTO mandaty VALUES (12, 12, 11, 9);
INSERT INTO mandaty VALUES (13, 12, 15, 29);
INSERT INTO mandaty VALUES (14, 13, 1, 16);
INSERT INTO mandaty VALUES (15, 14, 15, 14);
INSERT INTO mandaty VALUES (16, 14, 2, 2);
INSERT INTO mandaty VALUES (17, 15, 7, 11);
INSERT INTO mandaty VALUES (18, 15, 12, 11);
INSERT INTO mandaty VALUES (19, 16, 8, 9);
INSERT INTO mandaty VALUES (20, 16, 7, 6);
INSERT INTO mandaty VALUES (21, 16, 12, 17);
INSERT INTO mandaty VALUES (22, 17, 1, 14);
INSERT INTO mandaty VALUES (23, 17, 10, 7);
INSERT INTO mandaty VALUES (24, 17, 16, 12);
INSERT INTO mandaty VALUES (25, 18, 9, 27);
INSERT INTO mandaty VALUES (26, 18, 9, 32);
INSERT INTO mandaty VALUES (27, 19, 13, 13);
INSERT INTO mandaty VALUES (28, 19, 9, 21);
INSERT INTO mandaty VALUES (29, 19, 14, 1);
INSERT INTO mandaty VALUES (30, 21, 12, 32);
INSERT INTO mandaty VALUES (31, 21, 16, 29);
INSERT INTO mandaty VALUES (32, 23, 15, 7);
INSERT INTO mandaty VALUES (33, 23, 14, 9);
INSERT INTO mandaty VALUES (34, 23, 15, 32);
INSERT INTO mandaty VALUES (35, 24, 14, 1);
INSERT INTO mandaty VALUES (36, 24, 8, 30);
INSERT INTO mandaty VALUES (37, 25, 3, 14);
INSERT INTO mandaty VALUES (38, 26, 15, 30);
INSERT INTO mandaty VALUES (39, 26, 9, 30);
INSERT INTO mandaty VALUES (40, 26, 4, 8);
INSERT INTO mandaty VALUES (41, 27, 7, 32);
INSERT INTO mandaty VALUES (42, 27, 15, 24);
INSERT INTO mandaty VALUES (43, 31, 10, 3);
INSERT INTO mandaty VALUES (44, 33, 12, 23);
INSERT INTO mandaty VALUES (45, 34, 14, 22);
INSERT INTO mandaty VALUES (46, 35, 12, 26);
INSERT INTO mandaty VALUES (47, 35, 5, 8);
INSERT INTO mandaty VALUES (48, 38, 9, 31);
INSERT INTO mandaty VALUES (49, 38, 15, 21);
INSERT INTO mandaty VALUES (50, 38, 3, 6);
INSERT INTO mandaty VALUES (51, 41, 6, 30);
INSERT INTO mandaty VALUES (52, 44, 12, 32);
INSERT INTO mandaty VALUES (53, 44, 4, 12);
INSERT INTO mandaty VALUES (54, 44, 3, 18);
INSERT INTO mandaty VALUES (55, 45, 2, 25);
INSERT INTO mandaty VALUES (56, 46, 6, 8);
INSERT INTO mandaty VALUES (57, 46, 4, 13);
INSERT INTO mandaty VALUES (58, 46, 5, 12);
INSERT INTO mandaty VALUES (59, 48, 2, 28);
INSERT INTO mandaty VALUES (60, 49, 7, 13);
INSERT INTO mandaty VALUES (61, 49, 3, 9);
INSERT INTO mandaty VALUES (62, 49, 8, 3);
INSERT INTO mandaty VALUES (63, 50, 13, 16);
INSERT INTO mandaty VALUES (64, 50, 13, 18);
INSERT INTO mandaty VALUES (65, 52, 12, 23);
INSERT INTO mandaty VALUES (66, 52, 15, 20);
INSERT INTO mandaty VALUES (67, 53, 15, 32);
INSERT INTO mandaty VALUES (68, 54, 9, 8);
INSERT INTO mandaty VALUES (69, 54, 9, 31);
INSERT INTO mandaty VALUES (70, 54, 14, 20);
INSERT INTO mandaty VALUES (71, 55, 11, 22);
INSERT INTO mandaty VALUES (72, 55, 12, 2);
INSERT INTO mandaty VALUES (73, 55, 14, 4);
INSERT INTO mandaty VALUES (74, 58, 14, 12);
INSERT INTO mandaty VALUES (75, 58, 13, 22);
INSERT INTO mandaty VALUES (76, 62, 8, 16);
INSERT INTO mandaty VALUES (77, 62, 2, 23);
INSERT INTO mandaty VALUES (78, 62, 3, 6);
INSERT INTO mandaty VALUES (79, 63, 8, 13);
INSERT INTO mandaty VALUES (80, 63, 1, 12);
INSERT INTO mandaty VALUES (81, 63, 1, 6);
INSERT INTO mandaty VALUES (82, 64, 6, 2);
INSERT INTO mandaty VALUES (83, 64, 13, 6);
INSERT INTO mandaty VALUES (84, 65, 12, 27);
INSERT INTO mandaty VALUES (85, 65, 9, 30);
INSERT INTO mandaty VALUES (86, 69, 14, 23);
INSERT INTO mandaty VALUES (87, 69, 5, 6);
INSERT INTO mandaty VALUES (88, 71, 15, 29);
INSERT INTO mandaty VALUES (89, 76, 16, 24);
INSERT INTO mandaty VALUES (90, 77, 16, 23);
INSERT INTO mandaty VALUES (91, 77, 12, 9);
INSERT INTO mandaty VALUES (92, 78, 16, 16);
INSERT INTO mandaty VALUES (93, 78, 6, 10);
INSERT INTO mandaty VALUES (94, 78, 9, 17);
INSERT INTO mandaty VALUES (95, 81, 12, 9);
INSERT INTO mandaty VALUES (96, 81, 2, 23);
INSERT INTO mandaty VALUES (97, 83, 12, 18);
INSERT INTO mandaty VALUES (98, 84, 14, 1);
INSERT INTO mandaty VALUES (99, 84, 14, 19);
INSERT INTO mandaty VALUES (100, 85, 15, 30);
INSERT INTO mandaty VALUES (101, 85, 1, 28);
INSERT INTO mandaty VALUES (102, 85, 7, 30);
INSERT INTO mandaty VALUES (103, 87, 1, 6);
INSERT INTO mandaty VALUES (104, 88, 16, 13);
INSERT INTO mandaty VALUES (105, 89, 6, 24);
INSERT INTO mandaty VALUES (106, 90, 14, 8);
INSERT INTO mandaty VALUES (107, 90, 11, 9);
INSERT INTO mandaty VALUES (108, 91, 8, 18);
INSERT INTO mandaty VALUES (109, 91, 8, 23);
INSERT INTO mandaty VALUES (110, 92, 14, 17);
INSERT INTO mandaty VALUES (111, 92, 9, 11);
INSERT INTO mandaty VALUES (112, 92, 10, 19);
INSERT INTO mandaty VALUES (113, 94, 3, 7);
INSERT INTO mandaty VALUES (114, 95, 5, 18);
INSERT INTO mandaty VALUES (115, 96, 3, 8);
INSERT INTO mandaty VALUES (116, 96, 3, 19);
INSERT INTO mandaty VALUES (117, 97, 15, 10);
INSERT INTO mandaty VALUES (118, 97, 16, 10);
INSERT INTO mandaty VALUES (119, 98, 2, 3);
INSERT INTO mandaty VALUES (120, 99, 7, 27);
INSERT INTO mandaty VALUES (121, 99, 3, 28);
INSERT INTO mandaty VALUES (122, 100, 10, 22);
INSERT INTO mandaty VALUES (123, 100, 5, 29);
INSERT INTO egzaminy VALUES (1, '2007-02-15', 'teoria', 17, 3);
INSERT INTO egzaminy VALUES (2, '2007-03-08', 'teoria', 6, 12);
INSERT INTO egzaminy VALUES (3, '2007-03-15', 'praktyka', 19, 6);
INSERT INTO egzaminy VALUES (4, '2009-11-23', 'teoria', 6, 9);
INSERT INTO egzaminy VALUES (5, '2009-11-30', 'praktyka', 11, 11);
INSERT INTO egzaminy VALUES (6, '2009-12-21', 'praktyka', 32, 13);
INSERT INTO egzaminy VALUES (7, '2010-01-11', 'praktyka', 1, 13);
INSERT INTO egzaminy VALUES (8, '2004-05-26', 'teoria', 32, 1);
INSERT INTO egzaminy VALUES (9, '2004-06-02', 'praktyka', 12, 15);
INSERT INTO egzaminy VALUES (10, '2009-10-08', 'teoria', 21, 16);
INSERT INTO egzaminy VALUES (11, '2009-10-29', 'teoria', 25, 11);
INSERT INTO egzaminy VALUES (12, '2009-11-05', 'praktyka', 7, 12);
INSERT INTO egzaminy VALUES (13, '2009-11-26', 'praktyka', 18, 16);
INSERT INTO egzaminy VALUES (14, '2009-12-17', 'praktyka', 27, 6);
INSERT INTO egzaminy VALUES (15, '2014-01-05', 'teoria', 28, 12);
INSERT INTO egzaminy VALUES (16, '2014-01-12', 'praktyka', 11, 9);
INSERT INTO egzaminy VALUES (17, '2014-02-02', 'praktyka', 26, 2);
INSERT INTO egzaminy VALUES (18, '2014-02-23', 'praktyka', 21, 10);
INSERT INTO egzaminy VALUES (19, '2008-03-01', 'teoria', 10, 11);
INSERT INTO egzaminy VALUES (20, '2008-03-22', 'teoria', 22, 13);
INSERT INTO egzaminy VALUES (21, '2008-03-29', 'praktyka', 29, 13);
INSERT INTO egzaminy VALUES (22, '2008-04-19', 'praktyka', 26, 9);
INSERT INTO egzaminy VALUES (23, '2012-11-14', 'teoria', 2, 8);
INSERT INTO egzaminy VALUES (24, '2012-11-21', 'praktyka', 13, 12);
INSERT INTO egzaminy VALUES (25, '2009-10-26', 'teoria', 18, 13);
INSERT INTO egzaminy VALUES (26, '2009-11-02', 'praktyka', 8, 11);
INSERT INTO egzaminy VALUES (27, '2009-11-23', 'praktyka', 11, 5);
INSERT INTO egzaminy VALUES (28, '2009-12-14', 'praktyka', 11, 13);
INSERT INTO egzaminy VALUES (29, '2008-04-16', 'teoria', 20, 2);
INSERT INTO egzaminy VALUES (30, '2008-05-07', 'teoria', 20, 15);
INSERT INTO egzaminy VALUES (31, '2008-05-14', 'praktyka', 8, 7);
INSERT INTO egzaminy VALUES (32, '2008-06-04', 'praktyka', 8, 3);
INSERT INTO egzaminy VALUES (33, '2008-06-25', 'praktyka', 15, 5);
INSERT INTO egzaminy VALUES (34, '2010-08-04', 'teoria', 22, 10);
INSERT INTO egzaminy VALUES (35, '2010-08-11', 'praktyka', 31, 8);
INSERT INTO egzaminy VALUES (36, '2005-10-22', 'teoria', 28, 10);
INSERT INTO egzaminy VALUES (37, '2005-10-29', 'praktyka', 3, 9);
INSERT INTO egzaminy VALUES (38, '2005-11-19', 'praktyka', 1, 2);
INSERT INTO egzaminy VALUES (39, '2004-08-01', 'teoria', 16, 2);
INSERT INTO egzaminy VALUES (40, '2004-08-22', 'teoria', 11, 10);
INSERT INTO egzaminy VALUES (41, '2004-08-29', 'praktyka', 16, 15);
INSERT INTO egzaminy VALUES (42, '2004-09-19', 'praktyka', 22, 11);
INSERT INTO egzaminy VALUES (43, '2004-10-10', 'praktyka', 13, 2);
INSERT INTO egzaminy VALUES (44, '2004-08-14', 'teoria', 5, 5);
INSERT INTO egzaminy VALUES (45, '2004-08-21', 'praktyka', 8, 1);
INSERT INTO egzaminy VALUES (46, '2004-09-11', 'praktyka', 1, 13);
INSERT INTO egzaminy VALUES (47, '2015-01-23', 'teoria', 3, 10);
INSERT INTO egzaminy VALUES (48, '2015-02-13', 'teoria', 10, 1);
INSERT INTO egzaminy VALUES (49, '2015-02-20', 'praktyka', 8, 6);
INSERT INTO egzaminy VALUES (50, '2008-11-22', 'teoria', 24, 7);
INSERT INTO egzaminy VALUES (51, '2008-11-29', 'praktyka', 26, 16);
INSERT INTO egzaminy VALUES (52, '2008-12-20', 'praktyka', 9, 14);
INSERT INTO egzaminy VALUES (53, '2009-01-10', 'praktyka', 9, 16);
INSERT INTO egzaminy VALUES (54, '2008-12-13', 'teoria', 10, 13);
INSERT INTO egzaminy VALUES (55, '2008-12-20', 'praktyka', 24, 5);
INSERT INTO egzaminy VALUES (56, '2006-08-14', 'teoria', 25, 14);
INSERT INTO egzaminy VALUES (57, '2006-08-21', 'praktyka', 2, 9);
INSERT INTO egzaminy VALUES (58, '2006-09-11', 'praktyka', 14, 2);
INSERT INTO egzaminy VALUES (59, '2006-10-02', 'praktyka', 17, 1);
INSERT INTO egzaminy VALUES (60, '2008-04-15', 'teoria', 5, 6);
INSERT INTO egzaminy VALUES (61, '2008-04-22', 'praktyka', 6, 3);
INSERT INTO egzaminy VALUES (62, '2008-05-13', 'praktyka', 16, 3);
INSERT INTO egzaminy VALUES (63, '2010-01-19', 'teoria', 20, 1);
INSERT INTO egzaminy VALUES (64, '2010-01-26', 'praktyka', 17, 10);
INSERT INTO egzaminy VALUES (65, '2010-02-16', 'praktyka', 31, 15);
INSERT INTO egzaminy VALUES (66, '2010-02-09', 'teoria', 13, 1);
INSERT INTO egzaminy VALUES (67, '2010-03-02', 'teoria', 11, 10);
INSERT INTO egzaminy VALUES (68, '2010-03-09', 'praktyka', 1, 11);
INSERT INTO egzaminy VALUES (69, '2010-03-02', 'teoria', 5, 14);
INSERT INTO egzaminy VALUES (70, '2010-03-09', 'praktyka', 8, 7);
INSERT INTO egzaminy VALUES (71, '2010-03-30', 'praktyka', 11, 14);
INSERT INTO egzaminy VALUES (72, '2010-04-20', 'praktyka', 25, 8);
INSERT INTO egzaminy VALUES (73, '2010-03-23', 'teoria', 21, 10);
INSERT INTO egzaminy VALUES (74, '2010-03-30', 'praktyka', 18, 16);
INSERT INTO egzaminy VALUES (75, '2010-04-20', 'praktyka', 22, 1);
INSERT INTO egzaminy VALUES (76, '2010-05-11', 'praktyka', 31, 15);
INSERT INTO egzaminy VALUES (77, '2008-10-08', 'teoria', 6, 8);
INSERT INTO egzaminy VALUES (78, '2008-10-15', 'praktyka', 2, 1);
INSERT INTO egzaminy VALUES (79, '2008-11-05', 'praktyka', 11, 11);
INSERT INTO egzaminy VALUES (80, '2008-11-26', 'praktyka', 4, 12);
INSERT INTO egzaminy VALUES (81, '2011-06-20', 'teoria', 23, 15);
INSERT INTO egzaminy VALUES (82, '2011-06-27', 'praktyka', 15, 8);
INSERT INTO egzaminy VALUES (83, '2008-11-29', 'teoria', 2, 3);
INSERT INTO egzaminy VALUES (84, '2008-12-20', 'teoria', 16, 16);
INSERT INTO egzaminy VALUES (85, '2008-12-27', 'praktyka', 3, 7);
INSERT INTO egzaminy VALUES (86, '2007-03-03', 'teoria', 12, 11);
INSERT INTO egzaminy VALUES (87, '2007-03-24', 'teoria', 22, 12);
INSERT INTO egzaminy VALUES (88, '2007-03-31', 'praktyka', 4, 8);
INSERT INTO egzaminy VALUES (89, '2005-04-27', 'teoria', 12, 8);
INSERT INTO egzaminy VALUES (90, '2005-05-18', 'teoria', 29, 9);
INSERT INTO egzaminy VALUES (91, '2005-05-25', 'praktyka', 7, 8);
INSERT INTO egzaminy VALUES (92, '2005-06-15', 'praktyka', 11, 14);
INSERT INTO egzaminy VALUES (93, '2005-05-18', 'teoria', 32, 12);
INSERT INTO egzaminy VALUES (94, '2005-06-08', 'teoria', 2, 1);
INSERT INTO egzaminy VALUES (95, '2005-06-15', 'praktyka', 6, 14);
INSERT INTO egzaminy VALUES (96, '2005-06-08', 'teoria', 10, 12);
INSERT INTO egzaminy VALUES (97, '2005-06-29', 'teoria', 31, 7);
INSERT INTO egzaminy VALUES (98, '2005-07-06', 'praktyka', 2, 10);
INSERT INTO egzaminy VALUES (99, '2005-07-27', 'praktyka', 11, 5);
INSERT INTO egzaminy VALUES (100, '2005-08-17', 'praktyka', 29, 11);
INSERT INTO egzaminy VALUES (101, '2007-06-14', 'teoria', 15, 6);
INSERT INTO egzaminy VALUES (102, '2007-07-05', 'teoria', 17, 13);
INSERT INTO egzaminy VALUES (103, '2007-07-12', 'praktyka', 20, 2);
INSERT INTO egzaminy VALUES (104, '2007-08-02', 'praktyka', 26, 10);
INSERT INTO egzaminy VALUES (105, '2007-08-23', 'praktyka', 17, 1);
INSERT INTO egzaminy VALUES (106, '2010-07-17', 'teoria', 14, 3);
INSERT INTO egzaminy VALUES (107, '2010-08-07', 'teoria', 17, 5);
INSERT INTO egzaminy VALUES (108, '2010-08-14', 'praktyka', 16, 7);
INSERT INTO egzaminy VALUES (109, '2010-09-04', 'praktyka', 20, 13);
INSERT INTO egzaminy VALUES (110, '2011-05-11', 'teoria', 30, 16);
INSERT INTO egzaminy VALUES (111, '2011-06-01', 'teoria', 17, 16);
INSERT INTO egzaminy VALUES (112, '2011-06-08', 'praktyka', 2, 1);
INSERT INTO egzaminy VALUES (113, '2011-06-01', 'teoria', 23, 8);
INSERT INTO egzaminy VALUES (114, '2011-06-08', 'praktyka', 24, 9);
INSERT INTO egzaminy VALUES (115, '2011-06-29', 'praktyka', 13, 12);
INSERT INTO egzaminy VALUES (116, '2011-06-22', 'teoria', 6, 2);
INSERT INTO egzaminy VALUES (117, '2011-07-13', 'teoria', 3, 5);
INSERT INTO egzaminy VALUES (118, '2011-07-20', 'praktyka', 1, 4);
INSERT INTO egzaminy VALUES (119, '2011-08-10', 'praktyka', 3, 12);
INSERT INTO egzaminy VALUES (120, '2011-08-09', 'teoria', 10, 15);
INSERT INTO egzaminy VALUES (121, '2011-08-16', 'praktyka', 24, 15);
INSERT INTO egzaminy VALUES (122, '2011-09-06', 'praktyka', 3, 3);
INSERT INTO egzaminy VALUES (123, '2004-06-10', 'teoria', 11, 6);
INSERT INTO egzaminy VALUES (124, '2004-07-01', 'teoria', 5, 4);
INSERT INTO egzaminy VALUES (125, '2004-07-08', 'praktyka', 10, 12);
INSERT INTO egzaminy VALUES (126, '2004-07-29', 'praktyka', 3, 16);
INSERT INTO egzaminy VALUES (127, '2004-08-19', 'praktyka', 28, 1);
INSERT INTO egzaminy VALUES (128, '2004-07-01', 'teoria', 30, 9);
INSERT INTO egzaminy VALUES (129, '2004-07-08', 'praktyka', 3, 13);
INSERT INTO egzaminy VALUES (130, '2005-03-23', 'teoria', 7, 14);
INSERT INTO egzaminy VALUES (131, '2005-04-13', 'teoria', 28, 14);
INSERT INTO egzaminy VALUES (132, '2005-04-20', 'praktyka', 15, 1);
INSERT INTO egzaminy VALUES (133, '2005-05-11', 'praktyka', 4, 12);
INSERT INTO egzaminy VALUES (134, '2004-07-10', 'teoria', 12, 9);
INSERT INTO egzaminy VALUES (135, '2004-07-31', 'teoria', 12, 14);
INSERT INTO egzaminy VALUES (136, '2004-08-07', 'praktyka', 3, 11);
INSERT INTO egzaminy VALUES (137, '2004-07-31', 'teoria', 3, 14);
INSERT INTO egzaminy VALUES (138, '2004-08-21', 'teoria', 20, 16);
INSERT INTO egzaminy VALUES (139, '2004-08-28', 'praktyka', 17, 15);
INSERT INTO egzaminy VALUES (140, '2004-08-21', 'teoria', 12, 8);
INSERT INTO egzaminy VALUES (141, '2004-08-28', 'praktyka', 6, 6);
INSERT INTO egzaminy VALUES (142, '2013-09-05', 'teoria', 28, 13);
INSERT INTO egzaminy VALUES (143, '2013-09-26', 'teoria', 14, 13);
INSERT INTO egzaminy VALUES (144, '2013-10-03', 'praktyka', 8, 12);
INSERT INTO egzaminy VALUES (145, '2013-10-24', 'praktyka', 17, 11);
INSERT INTO egzaminy VALUES (146, '2011-11-07', 'teoria', 15, 12);
INSERT INTO egzaminy VALUES (147, '2011-11-14', 'praktyka', 12, 11);
INSERT INTO egzaminy VALUES (148, '2011-12-05', 'praktyka', 8, 14);
INSERT INTO egzaminy VALUES (149, '2011-12-26', 'praktyka', 6, 3);
INSERT INTO egzaminy VALUES (150, '2009-04-27', 'teoria', 11, 7);
INSERT INTO egzaminy VALUES (151, '2009-05-04', 'praktyka', 24, 9);
INSERT INTO egzaminy VALUES (152, '2009-05-25', 'praktyka', 21, 2);
INSERT INTO egzaminy VALUES (153, '2009-07-25', 'teoria', 1, 14);
INSERT INTO egzaminy VALUES (154, '2009-08-01', 'praktyka', 17, 3);
INSERT INTO egzaminy VALUES (155, '2009-08-22', 'praktyka', 13, 6);
INSERT INTO egzaminy VALUES (156, '2009-08-15', 'teoria', 17, 16);
INSERT INTO egzaminy VALUES (157, '2009-08-22', 'praktyka', 23, 2);
INSERT INTO egzaminy VALUES (158, '2009-09-12', 'praktyka', 13, 15);
INSERT INTO egzaminy VALUES (159, '2009-09-05', 'teoria', 8, 8);
INSERT INTO egzaminy VALUES (160, '2009-09-12', 'praktyka', 30, 2);
INSERT INTO egzaminy VALUES (161, '2005-01-22', 'teoria', 9, 13);
INSERT INTO egzaminy VALUES (162, '2005-02-12', 'teoria', 9, 13);
INSERT INTO egzaminy VALUES (163, '2005-02-19', 'praktyka', 24, 7);
INSERT INTO egzaminy VALUES (164, '2005-03-12', 'praktyka', 32, 7);
INSERT INTO egzaminy VALUES (165, '2005-02-12', 'teoria', 25, 10);
INSERT INTO egzaminy VALUES (166, '2005-02-19', 'praktyka', 17, 12);
INSERT INTO egzaminy VALUES (167, '2009-11-13', 'teoria', 4, 8);
INSERT INTO egzaminy VALUES (168, '2009-11-20', 'praktyka', 12, 16);
INSERT INTO egzaminy VALUES (169, '2015-02-23', 'teoria', 10, 10);
INSERT INTO egzaminy VALUES (170, '2015-03-02', 'praktyka', 30, 4);
INSERT INTO egzaminy VALUES (171, '2015-03-23', 'praktyka', 10, 1);
INSERT INTO egzaminy VALUES (172, '2015-04-13', 'praktyka', 31, 1);
INSERT INTO egzaminy VALUES (173, '2015-03-16', 'teoria', 22, 10);
INSERT INTO egzaminy VALUES (174, '2015-04-06', 'teoria', 6, 10);
INSERT INTO egzaminy VALUES (175, '2015-04-13', 'praktyka', 3, 14);
INSERT INTO egzaminy VALUES (176, '2015-04-06', 'teoria', 2, 15);
INSERT INTO egzaminy VALUES (177, '2015-04-13', 'praktyka', 28, 6);
INSERT INTO egzaminy VALUES (178, '2015-05-04', 'praktyka', 11, 4);
INSERT INTO egzaminy VALUES (179, '2009-07-12', 'teoria', 11, 9);
INSERT INTO egzaminy VALUES (180, '2009-07-19', 'praktyka', 26, 2);
INSERT INTO egzaminy VALUES (181, '2009-08-09', 'praktyka', 32, 10);
INSERT INTO egzaminy VALUES (182, '2009-08-02', 'teoria', 27, 11);
INSERT INTO egzaminy VALUES (183, '2009-08-09', 'praktyka', 30, 15);
INSERT INTO egzaminy VALUES (184, '2009-08-30', 'praktyka', 23, 14);
INSERT INTO egzaminy VALUES (185, '2009-09-20', 'praktyka', 22, 9);
INSERT INTO egzaminy VALUES (186, '2014-03-03', 'teoria', 30, 4);
INSERT INTO egzaminy VALUES (187, '2014-03-24', 'teoria', 22, 14);
INSERT INTO egzaminy VALUES (188, '2014-03-31', 'praktyka', 15, 8);
INSERT INTO egzaminy VALUES (189, '2013-10-30', 'teoria', 15, 11);
INSERT INTO egzaminy VALUES (190, '2013-11-20', 'teoria', 27, 7);
INSERT INTO egzaminy VALUES (191, '2013-11-27', 'praktyka', 1, 5);
INSERT INTO egzaminy VALUES (192, '2013-07-06', 'teoria', 6, 11);
INSERT INTO egzaminy VALUES (193, '2013-07-27', 'teoria', 21, 1);
INSERT INTO egzaminy VALUES (194, '2013-08-03', 'praktyka', 14, 11);
INSERT INTO egzaminy VALUES (195, '2013-08-24', 'praktyka', 16, 6);
INSERT INTO egzaminy VALUES (196, '2013-09-14', 'praktyka', 5, 2);
INSERT INTO egzaminy VALUES (197, '2013-07-27', 'teoria', 32, 13);
INSERT INTO egzaminy VALUES (198, '2013-08-03', 'praktyka', 21, 11);
INSERT INTO egzaminy VALUES (199, '2013-08-24', 'praktyka', 20, 13);
INSERT INTO egzaminy VALUES (200, '2013-09-14', 'praktyka', 32, 13);
INSERT INTO egzaminy VALUES (201, '2013-08-17', 'teoria', 16, 2);
INSERT INTO egzaminy VALUES (202, '2013-08-24', 'praktyka', 6, 10);
INSERT INTO egzaminy VALUES (203, '2007-05-03', 'teoria', 28, 6);
INSERT INTO egzaminy VALUES (204, '2007-05-24', 'teoria', 16, 10);
INSERT INTO egzaminy VALUES (205, '2007-05-31', 'praktyka', 28, 12);
INSERT INTO egzaminy VALUES (206, '2007-06-21', 'praktyka', 1, 11);
INSERT INTO egzaminy VALUES (207, '2004-12-29', 'teoria', 21, 1);
INSERT INTO egzaminy VALUES (208, '2005-01-05', 'praktyka', 17, 8);
INSERT INTO egzaminy VALUES (209, '2005-01-26', 'praktyka', 18, 4);
INSERT INTO egzaminy VALUES (210, '2005-02-16', 'praktyka', 17, 15);
INSERT INTO egzaminy VALUES (211, '2013-01-22', 'teoria', 8, 14);
INSERT INTO egzaminy VALUES (212, '2013-01-29', 'praktyka', 30, 6);
INSERT INTO egzaminy VALUES (213, '2013-02-19', 'praktyka', 5, 9);
INSERT INTO egzaminy VALUES (214, '2013-03-12', 'praktyka', 5, 13);
INSERT INTO egzaminy VALUES (215, '2012-05-26', 'teoria', 11, 2);
INSERT INTO egzaminy VALUES (216, '2012-06-16', 'teoria', 1, 11);
INSERT INTO egzaminy VALUES (217, '2012-06-23', 'praktyka', 17, 2);
INSERT INTO egzaminy VALUES (218, '2008-12-21', 'teoria', 10, 12);
INSERT INTO egzaminy VALUES (219, '2009-01-11', 'teoria', 25, 10);
INSERT INTO egzaminy VALUES (220, '2009-01-18', 'praktyka', 26, 6);
INSERT INTO egzaminy VALUES (221, '2009-01-11', 'teoria', 13, 1);
INSERT INTO egzaminy VALUES (222, '2009-02-01', 'teoria', 27, 9);
INSERT INTO egzaminy VALUES (223, '2009-02-08', 'praktyka', 1, 15);
INSERT INTO egzaminy VALUES (224, '2009-03-01', 'praktyka', 18, 15);
INSERT INTO egzaminy VALUES (225, '2009-03-22', 'praktyka', 8, 14);
INSERT INTO egzaminy VALUES (226, '2009-02-01', 'teoria', 24, 10);
INSERT INTO egzaminy VALUES (227, '2009-02-08', 'praktyka', 10, 4);
INSERT INTO egzaminy VALUES (228, '2014-04-04', 'teoria', 24, 3);
INSERT INTO egzaminy VALUES (229, '2014-04-25', 'teoria', 18, 16);
INSERT INTO egzaminy VALUES (230, '2014-05-02', 'praktyka', 15, 6);
INSERT INTO egzaminy VALUES (231, '2014-05-23', 'praktyka', 20, 13);
INSERT INTO egzaminy VALUES (232, '2014-06-13', 'praktyka', 27, 11);
INSERT INTO egzaminy VALUES (233, '2006-11-15', 'teoria', 9, 4);
INSERT INTO egzaminy VALUES (234, '2006-12-06', 'teoria', 7, 13);
INSERT INTO egzaminy VALUES (235, '2006-12-13', 'praktyka', 22, 3);
INSERT INTO egzaminy VALUES (236, '2007-01-03', 'praktyka', 26, 13);
INSERT INTO egzaminy VALUES (237, '2007-01-24', 'praktyka', 4, 3);
INSERT INTO egzaminy VALUES (238, '2006-12-06', 'teoria', 25, 5);
INSERT INTO egzaminy VALUES (239, '2006-12-27', 'teoria', 30, 13);
INSERT INTO egzaminy VALUES (240, '2007-01-03', 'praktyka', 14, 3);
INSERT INTO egzaminy VALUES (241, '2014-01-19', 'teoria', 6, 4);
INSERT INTO egzaminy VALUES (242, '2014-01-26', 'praktyka', 7, 12);
INSERT INTO egzaminy VALUES (243, '2014-02-16', 'praktyka', 24, 1);
INSERT INTO egzaminy VALUES (244, '2012-08-29', 'teoria', 14, 16);
INSERT INTO egzaminy VALUES (245, '2012-09-19', 'teoria', 12, 14);
INSERT INTO egzaminy VALUES (246, '2012-09-26', 'praktyka', 26, 9);
INSERT INTO egzaminy VALUES (247, '2012-10-17', 'praktyka', 6, 5);
INSERT INTO egzaminy VALUES (248, '2012-11-07', 'praktyka', 13, 3);
INSERT INTO egzaminy VALUES (249, '2012-09-19', 'teoria', 22, 15);
INSERT INTO egzaminy VALUES (250, '2012-10-10', 'teoria', 8, 8);
INSERT INTO egzaminy VALUES (251, '2012-10-17', 'praktyka', 2, 12);
INSERT INTO egzaminy VALUES (252, '2012-11-07', 'praktyka', 25, 5);
INSERT INTO egzaminy VALUES (253, '2012-11-28', 'praktyka', 14, 16);
INSERT INTO egzaminy VALUES (254, '2004-10-01', 'teoria', 12, 8);
INSERT INTO egzaminy VALUES (255, '2004-10-22', 'teoria', 12, 3);
INSERT INTO egzaminy VALUES (256, '2004-10-29', 'praktyka', 3, 3);
INSERT INTO egzaminy VALUES (257, '2004-11-19', 'praktyka', 15, 3);
INSERT INTO egzaminy VALUES (258, '2004-10-22', 'teoria', 28, 16);
INSERT INTO egzaminy VALUES (259, '2004-11-12', 'teoria', 3, 16);
INSERT INTO egzaminy VALUES (260, '2004-11-19', 'praktyka', 26, 11);
INSERT INTO egzaminy VALUES (261, '2004-12-10', 'praktyka', 1, 10);
INSERT INTO egzaminy VALUES (262, '2004-11-12', 'teoria', 3, 4);
INSERT INTO egzaminy VALUES (263, '2004-11-19', 'praktyka', 11, 4);
INSERT INTO egzaminy VALUES (264, '2004-12-03', 'teoria', 24, 4);
INSERT INTO egzaminy VALUES (265, '2004-12-10', 'praktyka', 11, 1);
INSERT INTO egzaminy VALUES (266, '2015-03-02', 'teoria', 1, 11);
INSERT INTO egzaminy VALUES (267, '2015-03-23', 'teoria', 30, 6);
INSERT INTO egzaminy VALUES (268, '2015-03-30', 'praktyka', 8, 5);
INSERT INTO egzaminy VALUES (269, '2015-04-20', 'praktyka', 5, 10);
INSERT INTO egzaminy VALUES (270, '2011-03-03', 'teoria', 6, 16);
INSERT INTO egzaminy VALUES (271, '2011-03-24', 'teoria', 22, 13);
INSERT INTO egzaminy VALUES (272, '2011-03-31', 'praktyka', 14, 6);
INSERT INTO egzaminy VALUES (273, '2010-03-14', 'teoria', 31, 5);
INSERT INTO egzaminy VALUES (274, '2010-03-21', 'praktyka', 9, 5);
INSERT INTO egzaminy VALUES (275, '2004-04-08', 'teoria', 16, 16);
INSERT INTO egzaminy VALUES (276, '2004-04-29', 'teoria', 30, 8);
INSERT INTO egzaminy VALUES (277, '2004-05-06', 'praktyka', 14, 11);
INSERT INTO egzaminy VALUES (278, '2004-05-27', 'praktyka', 31, 14);
INSERT INTO egzaminy VALUES (279, '2004-06-17', 'praktyka', 10, 1);
INSERT INTO egzaminy VALUES (280, '2008-06-13', 'teoria', 32, 14);
INSERT INTO egzaminy VALUES (281, '2008-06-20', 'praktyka', 8, 8);
INSERT INTO egzaminy VALUES (282, '2008-07-04', 'teoria', 10, 11);
INSERT INTO egzaminy VALUES (283, '2008-07-11', 'praktyka', 20, 11);
INSERT INTO egzaminy VALUES (284, '2008-08-01', 'praktyka', 10, 5);
INSERT INTO egzaminy VALUES (285, '2008-08-22', 'praktyka', 1, 3);
INSERT INTO egzaminy VALUES (286, '2008-07-25', 'teoria', 14, 4);
INSERT INTO egzaminy VALUES (287, '2008-08-15', 'teoria', 12, 5);
INSERT INTO egzaminy VALUES (288, '2008-08-22', 'praktyka', 30, 9);
INSERT INTO egzaminy VALUES (289, '2008-08-15', 'teoria', 13, 2);
INSERT INTO egzaminy VALUES (290, '2008-08-22', 'praktyka', 31, 12);
INSERT INTO egzaminy VALUES (291, '2008-09-12', 'praktyka', 8, 9);
INSERT INTO egzaminy VALUES (292, '2008-10-03', 'praktyka', 11, 11);
INSERT INTO egzaminy VALUES (293, '2014-11-23', 'teoria', 2, 7);
INSERT INTO egzaminy VALUES (294, '2014-11-30', 'praktyka', 3, 15);
INSERT INTO egzaminy VALUES (295, '2014-12-14', 'teoria', 22, 9);
INSERT INTO egzaminy VALUES (296, '2014-12-21', 'praktyka', 7, 14);
INSERT INTO egzaminy VALUES (297, '2009-03-14', 'teoria', 30, 15);
INSERT INTO egzaminy VALUES (298, '2009-03-21', 'praktyka', 6, 4);
INSERT INTO egzaminy VALUES (299, '2009-04-11', 'praktyka', 18, 6);
INSERT INTO egzaminy VALUES (300, '2009-05-02', 'praktyka', 11, 10);
INSERT INTO egzaminy VALUES (301, '2009-04-04', 'teoria', 13, 2);
INSERT INTO egzaminy VALUES (302, '2009-04-25', 'teoria', 14, 3);
INSERT INTO egzaminy VALUES (303, '2009-05-02', 'praktyka', 9, 9);
INSERT INTO egzaminy VALUES (304, '2009-05-23', 'praktyka', 20, 13);
INSERT INTO egzaminy VALUES (305, '2009-06-13', 'praktyka', 28, 3);
INSERT INTO egzaminy VALUES (306, '2009-04-25', 'teoria', 8, 8);
INSERT INTO egzaminy VALUES (307, '2009-05-02', 'praktyka', 7, 16);
INSERT INTO egzaminy VALUES (308, '2009-05-23', 'praktyka', 10, 6);
INSERT INTO egzaminy VALUES (309, '2009-06-13', 'praktyka', 23, 7);
INSERT INTO egzaminy VALUES (310, '2009-05-16', 'teoria', 15, 4);
INSERT INTO egzaminy VALUES (311, '2009-06-06', 'teoria', 30, 12);
INSERT INTO egzaminy VALUES (312, '2009-06-13', 'praktyka', 3, 13);
INSERT INTO egzaminy VALUES (313, '2011-11-13', 'teoria', 6, 11);
INSERT INTO egzaminy VALUES (314, '2011-12-04', 'teoria', 5, 16);
INSERT INTO egzaminy VALUES (315, '2011-12-11', 'praktyka', 9, 13);
INSERT INTO egzaminy VALUES (316, '2013-12-26', 'teoria', 17, 11);
INSERT INTO egzaminy VALUES (317, '2014-01-02', 'praktyka', 27, 14);
INSERT INTO egzaminy VALUES (318, '2014-01-23', 'praktyka', 1, 6);
INSERT INTO egzaminy VALUES (319, '2014-02-13', 'praktyka', 15, 1);
INSERT INTO egzaminy VALUES (320, '2007-04-06', 'teoria', 24, 15);
INSERT INTO egzaminy VALUES (321, '2007-04-27', 'teoria', 1, 12);
INSERT INTO egzaminy VALUES (322, '2007-05-04', 'praktyka', 8, 14);
INSERT INTO egzaminy VALUES (323, '2007-05-25', 'praktyka', 3, 16);
INSERT INTO egzaminy VALUES (324, '2005-10-27', 'teoria', 17, 6);
INSERT INTO egzaminy VALUES (325, '2005-11-17', 'teoria', 32, 8);
INSERT INTO egzaminy VALUES (326, '2005-11-24', 'praktyka', 14, 16);
INSERT INTO egzaminy VALUES (327, '2005-12-15', 'praktyka', 5, 15);
INSERT INTO egzaminy VALUES (328, '2006-01-05', 'praktyka', 31, 4);
INSERT INTO egzaminy VALUES (329, '2005-11-17', 'teoria', 3, 7);
INSERT INTO egzaminy VALUES (330, '2005-12-08', 'teoria', 26, 6);
INSERT INTO egzaminy VALUES (331, '2005-12-15', 'praktyka', 11, 5);
INSERT INTO egzaminy VALUES (332, '2006-01-05', 'praktyka', 11, 3);
INSERT INTO egzaminy VALUES (333, '2005-12-08', 'teoria', 19, 7);
INSERT INTO egzaminy VALUES (334, '2005-12-29', 'teoria', 19, 4);
INSERT INTO egzaminy VALUES (335, '2006-01-05', 'praktyka', 12, 4);
INSERT INTO egzaminy VALUES (336, '2006-01-26', 'praktyka', 16, 8);
INSERT INTO egzaminy VALUES (337, '2006-02-16', 'praktyka', 15, 8);
INSERT INTO egzaminy VALUES (338, '2005-09-09', 'teoria', 17, 13);
INSERT INTO egzaminy VALUES (339, '2005-09-16', 'praktyka', 14, 7);
INSERT INTO egzaminy VALUES (340, '2005-09-30', 'teoria', 13, 2);
INSERT INTO egzaminy VALUES (341, '2005-10-07', 'praktyka', 22, 16);
INSERT INTO egzaminy VALUES (342, '2014-09-25', 'teoria', 24, 13);
INSERT INTO egzaminy VALUES (343, '2014-10-02', 'praktyka', 32, 14);
INSERT INTO egzaminy VALUES (344, '2014-10-16', 'teoria', 19, 9);
INSERT INTO egzaminy VALUES (345, '2014-11-06', 'teoria', 1, 16);
INSERT INTO egzaminy VALUES (346, '2014-11-13', 'praktyka', 3, 8);
INSERT INTO egzaminy VALUES (347, '2014-12-04', 'praktyka', 20, 10);
INSERT INTO egzaminy VALUES (348, '2014-12-25', 'praktyka', 20, 14);
INSERT INTO egzaminy VALUES (349, '2010-10-08', 'teoria', 17, 2);
INSERT INTO egzaminy VALUES (350, '2010-10-29', 'teoria', 21, 3);
INSERT INTO egzaminy VALUES (351, '2010-11-05', 'praktyka', 23, 14);
INSERT INTO egzaminy VALUES (352, '2009-10-31', 'teoria', 23, 16);
INSERT INTO egzaminy VALUES (353, '2009-11-07', 'praktyka', 10, 9);
INSERT INTO egzaminy VALUES (354, '2009-11-28', 'praktyka', 25, 7);
INSERT INTO egzaminy VALUES (355, '2009-12-19', 'praktyka', 24, 3);
INSERT INTO egzaminy VALUES (356, '2009-11-21', 'teoria', 15, 2);
INSERT INTO egzaminy VALUES (357, '2009-11-28', 'praktyka', 13, 2);
INSERT INTO egzaminy VALUES (358, '2009-12-19', 'praktyka', 11, 1);
INSERT INTO egzaminy VALUES (359, '2010-01-09', 'praktyka', 18, 8);
INSERT INTO egzaminy VALUES (360, '2009-12-12', 'teoria', 14, 16);
INSERT INTO egzaminy VALUES (361, '2010-01-02', 'teoria', 17, 12);
INSERT INTO egzaminy VALUES (362, '2010-01-09', 'praktyka', 19, 1);
INSERT INTO egzaminy VALUES (363, '2010-01-30', 'praktyka', 28, 12);
INSERT INTO egzaminy VALUES (364, '2010-05-23', 'teoria', 22, 13);
INSERT INTO egzaminy VALUES (365, '2010-06-13', 'teoria', 28, 6);
INSERT INTO egzaminy VALUES (366, '2010-06-20', 'praktyka', 3, 9);
INSERT INTO egzaminy VALUES (367, '2010-07-11', 'praktyka', 21, 5);
INSERT INTO egzaminy VALUES (368, '2010-08-01', 'praktyka', 6, 15);
INSERT INTO egzaminy VALUES (369, '2010-06-13', 'teoria', 7, 14);
INSERT INTO egzaminy VALUES (370, '2010-07-04', 'teoria', 15, 16);
INSERT INTO egzaminy VALUES (371, '2010-07-11', 'praktyka', 5, 3);
INSERT INTO egzaminy VALUES (372, '2010-08-01', 'praktyka', 26, 3);
INSERT INTO egzaminy VALUES (373, '2010-08-22', 'praktyka', 9, 4);
INSERT INTO egzaminy VALUES (374, '2009-12-10', 'teoria', 9, 2);
INSERT INTO egzaminy VALUES (375, '2009-12-31', 'teoria', 30, 6);
INSERT INTO egzaminy VALUES (376, '2010-01-07', 'praktyka', 2, 15);
INSERT INTO egzaminy VALUES (377, '2011-03-21', 'teoria', 17, 8);
INSERT INTO egzaminy VALUES (378, '2011-04-11', 'teoria', 15, 11);
INSERT INTO egzaminy VALUES (379, '2011-04-18', 'praktyka', 20, 12);
INSERT INTO egzaminy VALUES (380, '2007-02-17', 'teoria', 20, 1);
INSERT INTO egzaminy VALUES (381, '2007-03-10', 'teoria', 24, 8);
INSERT INTO egzaminy VALUES (382, '2007-03-17', 'praktyka', 2, 16);
INSERT INTO egzaminy VALUES (383, '2007-04-07', 'praktyka', 18, 5);
INSERT INTO egzaminy VALUES (384, '2007-04-28', 'praktyka', 3, 5);
INSERT INTO egzaminy VALUES (385, '2007-03-10', 'teoria', 31, 11);
INSERT INTO egzaminy VALUES (386, '2007-03-31', 'teoria', 30, 13);
INSERT INTO egzaminy VALUES (387, '2007-04-07', 'praktyka', 18, 1);
INSERT INTO egzaminy VALUES (388, '2013-07-20', 'teoria', 11, 9);
INSERT INTO egzaminy VALUES (389, '2013-08-10', 'teoria', 19, 16);
INSERT INTO egzaminy VALUES (390, '2013-08-17', 'praktyka', 27, 10);
INSERT INTO egzaminy VALUES (391, '2013-08-10', 'teoria', 18, 11);
INSERT INTO egzaminy VALUES (392, '2013-08-31', 'teoria', 7, 5);
INSERT INTO egzaminy VALUES (393, '2013-09-07', 'praktyka', 7, 3);
INSERT INTO egzaminy VALUES (394, '2013-09-28', 'praktyka', 6, 14);
INSERT INTO egzaminy VALUES (395, '2013-10-19', 'praktyka', 12, 7);
INSERT INTO egzaminy VALUES (396, '2004-04-10', 'teoria', 15, 1);
INSERT INTO egzaminy VALUES (397, '2004-04-17', 'praktyka', 10, 15);
INSERT INTO egzaminy VALUES (398, '2004-05-08', 'praktyka', 29, 1);
INSERT INTO egzaminy VALUES (399, '2004-05-29', 'praktyka', 30, 5);
INSERT INTO egzaminy VALUES (400, '2005-11-03', 'teoria', 30, 9);
INSERT INTO egzaminy VALUES (401, '2005-11-10', 'praktyka', 17, 4);
INSERT INTO egzaminy VALUES (402, '2005-08-04', 'teoria', 2, 12);
INSERT INTO egzaminy VALUES (403, '2005-08-11', 'praktyka', 9, 10);
INSERT INTO egzaminy VALUES (404, '2005-09-01', 'praktyka', 7, 1);
INSERT INTO egzaminy VALUES (405, '2014-09-01', 'teoria', 22, 3);
INSERT INTO egzaminy VALUES (406, '2014-09-22', 'teoria', 18, 5);
INSERT INTO egzaminy VALUES (407, '2014-09-29', 'praktyka', 31, 9);
INSERT INTO egzaminy VALUES (408, '2014-10-20', 'praktyka', 27, 16);
INSERT INTO egzaminy VALUES (409, '2014-11-10', 'praktyka', 17, 1);
INSERT INTO egzaminy VALUES (410, '2011-04-05', 'teoria', 6, 13);
INSERT INTO egzaminy VALUES (411, '2011-04-12', 'praktyka', 32, 12);
INSERT INTO egzaminy VALUES (412, '2011-05-03', 'praktyka', 10, 4);
INSERT INTO egzaminy VALUES (413, '2011-05-24', 'praktyka', 10, 13);
INSERT INTO egzaminy VALUES (414, '2007-08-01', 'teoria', 1, 14);
INSERT INTO egzaminy VALUES (415, '2007-08-22', 'teoria', 6, 9);
INSERT INTO egzaminy VALUES (416, '2007-08-29', 'praktyka', 15, 15);
INSERT INTO egzaminy VALUES (417, '2007-01-09', 'teoria', 8, 10);
INSERT INTO egzaminy VALUES (418, '2007-01-16', 'praktyka', 30, 8);
INSERT INTO egzaminy VALUES (419, '2007-02-06', 'praktyka', 9, 11);
INSERT INTO egzaminy VALUES (420, '2008-09-12', 'teoria', 10, 1);
INSERT INTO egzaminy VALUES (421, '2008-10-03', 'teoria', 8, 16);
INSERT INTO egzaminy VALUES (422, '2008-10-10', 'praktyka', 16, 9);
INSERT INTO egzaminy VALUES (423, '2013-07-18', 'teoria', 28, 1);
INSERT INTO egzaminy VALUES (424, '2013-08-08', 'teoria', 15, 9);
INSERT INTO egzaminy VALUES (425, '2013-08-15', 'praktyka', 31, 2);
INSERT INTO egzaminy VALUES (426, '2013-08-08', 'teoria', 26, 1);
INSERT INTO egzaminy VALUES (427, '2013-08-15', 'praktyka', 25, 8);
INSERT INTO egzaminy VALUES (428, '2013-09-05', 'praktyka', 15, 10);
INSERT INTO egzaminy VALUES (429, '2013-09-26', 'praktyka', 28, 12);
INSERT INTO egzaminy VALUES (430, '2013-08-29', 'teoria', 10, 6);
INSERT INTO egzaminy VALUES (431, '2013-09-19', 'teoria', 5, 14);
INSERT INTO egzaminy VALUES (432, '2013-09-26', 'praktyka', 4, 15);
INSERT INTO egzaminy VALUES (433, '2013-10-17', 'praktyka', 15, 2);
INSERT INTO egzaminy VALUES (434, '2013-09-19', 'teoria', 13, 8);
INSERT INTO egzaminy VALUES (435, '2013-09-26', 'praktyka', 29, 4);
INSERT INTO egzaminy VALUES (436, '2013-05-18', 'teoria', 26, 11);
INSERT INTO egzaminy VALUES (437, '2013-06-08', 'teoria', 10, 10);
INSERT INTO egzaminy VALUES (438, '2013-06-15', 'praktyka', 25, 2);
INSERT INTO egzaminy VALUES (439, '2013-07-06', 'praktyka', 25, 12);
INSERT INTO egzaminy VALUES (440, '2013-07-27', 'praktyka', 12, 14);
INSERT INTO egzaminy VALUES (441, '2011-04-29', 'teoria', 14, 11);
INSERT INTO egzaminy VALUES (442, '2011-05-20', 'teoria', 6, 10);
INSERT INTO egzaminy VALUES (443, '2011-05-27', 'praktyka', 3, 2);
INSERT INTO egzaminy VALUES (444, '2011-06-17', 'praktyka', 20, 11);
INSERT INTO egzaminy VALUES (445, '2004-09-25', 'teoria', 14, 11);
INSERT INTO egzaminy VALUES (446, '2004-10-16', 'teoria', 27, 1);
INSERT INTO egzaminy VALUES (447, '2004-10-23', 'praktyka', 28, 3);
INSERT INTO egzaminy VALUES (448, '2004-11-13', 'praktyka', 12, 6);
INSERT INTO egzaminy VALUES (449, '2004-10-16', 'teoria', 23, 15);
INSERT INTO egzaminy VALUES (450, '2004-11-06', 'teoria', 8, 7);
INSERT INTO egzaminy VALUES (451, '2004-11-13', 'praktyka', 16, 6);
INSERT INTO egzaminy VALUES (452, '2004-12-04', 'praktyka', 24, 11);
INSERT INTO egzaminy VALUES (453, '2008-11-26', 'teoria', 32, 16);
INSERT INTO egzaminy VALUES (454, '2008-12-17', 'teoria', 19, 15);
INSERT INTO egzaminy VALUES (455, '2008-12-24', 'praktyka', 5, 10);
INSERT INTO egzaminy VALUES (456, '2009-01-14', 'praktyka', 15, 12);
INSERT INTO egzaminy VALUES (457, '2009-02-04', 'praktyka', 7, 4);
INSERT INTO egzaminy VALUES (458, '2011-10-12', 'teoria', 17, 1);
INSERT INTO egzaminy VALUES (459, '2011-10-19', 'praktyka', 8, 7);
INSERT INTO egzaminy VALUES (460, '2011-11-09', 'praktyka', 19, 11);
INSERT INTO egzaminy VALUES (461, '2011-11-30', 'praktyka', 18, 9);
INSERT INTO egzaminy VALUES (462, '2009-12-09', 'teoria', 18, 8);
INSERT INTO egzaminy VALUES (463, '2009-12-16', 'praktyka', 19, 8);
INSERT INTO egzaminy VALUES (464, '2008-01-22', 'teoria', 13, 14);
INSERT INTO egzaminy VALUES (465, '2008-01-29', 'praktyka', 23, 6);
INSERT INTO egzaminy VALUES (466, '2008-02-19', 'praktyka', 21, 14);
INSERT INTO egzaminy VALUES (467, '2008-03-11', 'praktyka', 12, 3);
INSERT INTO egzaminy VALUES (468, '2008-02-12', 'teoria', 1, 16);
INSERT INTO egzaminy VALUES (469, '2008-02-19', 'praktyka', 11, 10);
INSERT INTO egzaminy VALUES (470, '2008-03-11', 'praktyka', 4, 2);
INSERT INTO egzaminy VALUES (471, '2008-03-04', 'teoria', 1, 10);
INSERT INTO egzaminy VALUES (472, '2008-03-25', 'teoria', 27, 5);
INSERT INTO egzaminy VALUES (473, '2008-04-01', 'praktyka', 1, 10);
INSERT INTO egzaminy VALUES (474, '2008-03-25', 'teoria', 4, 14);
INSERT INTO egzaminy VALUES (475, '2008-04-01', 'praktyka', 29, 13);
INSERT INTO egzaminy VALUES (476, '2015-02-05', 'teoria', 19, 5);
INSERT INTO egzaminy VALUES (477, '2015-02-26', 'teoria', 9, 9);
INSERT INTO egzaminy VALUES (478, '2015-03-05', 'praktyka', 6, 3);
INSERT INTO egzaminy VALUES (479, '2015-02-26', 'teoria', 9, 11);
INSERT INTO egzaminy VALUES (480, '2015-03-19', 'teoria', 26, 7);
INSERT INTO egzaminy VALUES (481, '2015-03-26', 'praktyka', 8, 10);
INSERT INTO egzaminy VALUES (482, '2015-04-16', 'praktyka', 30, 5);
INSERT INTO egzaminy VALUES (483, '2012-11-17', 'teoria', 32, 16);
INSERT INTO egzaminy VALUES (484, '2012-11-24', 'praktyka', 2, 10);
INSERT INTO egzaminy VALUES (485, '2012-12-15', 'praktyka', 9, 4);
INSERT INTO egzaminy VALUES (486, '2010-10-01', 'teoria', 17, 13);
INSERT INTO egzaminy VALUES (487, '2010-10-22', 'teoria', 28, 3);
INSERT INTO egzaminy VALUES (488, '2010-10-29', 'praktyka', 22, 16);
INSERT INTO egzaminy VALUES (489, '2010-11-19', 'praktyka', 4, 13);
INSERT INTO egzaminy VALUES (490, '2010-12-10', 'praktyka', 9, 10);
INSERT INTO egzaminy VALUES (491, '2010-10-22', 'teoria', 7, 9);
INSERT INTO egzaminy VALUES (492, '2010-11-12', 'teoria', 24, 5);
INSERT INTO egzaminy VALUES (493, '2010-11-19', 'praktyka', 11, 7);
INSERT INTO egzaminy VALUES (494, '2004-03-27', 'teoria', 4, 8);
INSERT INTO egzaminy VALUES (495, '2004-04-03', 'praktyka', 8, 10);
INSERT INTO egzaminy VALUES (496, '2004-04-24', 'praktyka', 11, 3);
INSERT INTO egzaminy VALUES (497, '2004-04-17', 'teoria', 19, 14);
INSERT INTO egzaminy VALUES (498, '2004-05-08', 'teoria', 27, 6);
INSERT INTO egzaminy VALUES (499, '2004-05-15', 'praktyka', 8, 16);
INSERT INTO egzaminy VALUES (500, '2013-03-31', 'teoria', 16, 15);
INSERT INTO egzaminy VALUES (501, '2013-04-21', 'teoria', 3, 3);
INSERT INTO egzaminy VALUES (502, '2013-04-28', 'praktyka', 20, 4);
INSERT INTO egzaminy VALUES (503, '2013-05-19', 'praktyka', 29, 13);
INSERT INTO egzaminy VALUES (504, '2013-06-09', 'praktyka', 24, 5);
INSERT INTO egzaminy VALUES (505, '2005-05-02', 'teoria', 28, 10);
INSERT INTO egzaminy VALUES (506, '2005-05-23', 'teoria', 28, 4);
INSERT INTO egzaminy VALUES (507, '2005-05-30', 'praktyka', 32, 9);
INSERT INTO egzaminy VALUES (508, '2009-09-06', 'teoria', 3, 11);
INSERT INTO egzaminy VALUES (509, '2009-09-13', 'praktyka', 15, 3);
INSERT INTO egzaminy VALUES (510, '2009-10-04', 'praktyka', 18, 8);
INSERT INTO egzaminy VALUES (511, '2006-08-23', 'teoria', 14, 12);
INSERT INTO egzaminy VALUES (512, '2006-09-13', 'teoria', 29, 12);
INSERT INTO egzaminy VALUES (513, '2006-09-20', 'praktyka', 25, 16);
INSERT INTO egzaminy VALUES (514, '2006-09-13', 'teoria', 28, 16);
INSERT INTO egzaminy VALUES (515, '2006-09-20', 'praktyka', 13, 9);
INSERT INTO egzaminy VALUES (516, '2006-10-11', 'praktyka', 32, 7);
INSERT INTO egzaminy VALUES (517, '2006-10-04', 'teoria', 23, 1);
INSERT INTO egzaminy VALUES (518, '2006-10-25', 'teoria', 32, 2);
INSERT INTO egzaminy VALUES (519, '2006-11-01', 'praktyka', 23, 3);
INSERT INTO egzaminy VALUES (520, '2006-11-22', 'praktyka', 10, 9);
INSERT INTO egzaminy VALUES (521, '2006-10-25', 'teoria', 29, 5);
INSERT INTO egzaminy VALUES (522, '2006-11-22', 'praktyka', 20, 9);
INSERT INTO egzaminy VALUES (523, '2010-12-25', 'teoria', 26, 5);
INSERT INTO egzaminy VALUES (524, '2011-01-01', 'praktyka', 26, 10);
INSERT INTO egzaminy VALUES (525, '2006-04-15', 'teoria', 4, 7);
INSERT INTO egzaminy VALUES (526, '2006-05-06', 'teoria', 30, 9);
INSERT INTO egzaminy VALUES (527, '2006-05-13', 'praktyka', 9, 6);
INSERT INTO egzaminy VALUES (528, '2006-06-03', 'praktyka', 7, 14);
INSERT INTO egzaminy VALUES (529, '2006-05-06', 'teoria', 10, 6);
INSERT INTO egzaminy VALUES (530, '2006-05-13', 'praktyka', 8, 6);
INSERT INTO egzaminy VALUES (531, '2006-05-27', 'teoria', 30, 3);
INSERT INTO egzaminy VALUES (532, '2006-06-03', 'praktyka', 15, 3);
INSERT INTO egzaminy VALUES (533, '2006-06-24', 'praktyka', 7, 15);
INSERT INTO egzaminy VALUES (534, '2008-09-29', 'teoria', 22, 12);
INSERT INTO egzaminy VALUES (535, '2008-10-20', 'teoria', 19, 3);
INSERT INTO egzaminy VALUES (536, '2008-10-27', 'praktyka', 32, 9);
INSERT INTO egzaminy VALUES (537, '2008-11-17', 'praktyka', 4, 2);
INSERT INTO egzaminy VALUES (538, '2008-12-08', 'praktyka', 14, 14);
INSERT INTO egzaminy VALUES (539, '2014-07-12', 'teoria', 6, 11);
INSERT INTO egzaminy VALUES (540, '2014-08-02', 'teoria', 8, 14);
INSERT INTO egzaminy VALUES (541, '2014-08-09', 'praktyka', 30, 4);
INSERT INTO egzaminy VALUES (542, '2014-08-30', 'praktyka', 2, 3);
INSERT INTO egzaminy VALUES (543, '2014-09-20', 'praktyka', 24, 15);
INSERT INTO egzaminy VALUES (544, '2007-07-12', 'teoria', 24, 9);
INSERT INTO egzaminy VALUES (545, '2007-08-02', 'teoria', 3, 11);
INSERT INTO egzaminy VALUES (546, '2007-08-09', 'praktyka', 32, 7);
INSERT INTO egzaminy VALUES (547, '2007-08-02', 'teoria', 16, 15);
INSERT INTO egzaminy VALUES (548, '2007-08-09', 'praktyka', 16, 1);
INSERT INTO egzaminy VALUES (549, '2007-08-30', 'praktyka', 7, 5);
INSERT INTO egzaminy VALUES (550, '2007-09-20', 'praktyka', 25, 14);
INSERT INTO egzaminy VALUES (551, '2007-08-23', 'teoria', 25, 3);
INSERT INTO egzaminy VALUES (552, '2007-08-30', 'praktyka', 12, 10);
INSERT INTO egzaminy VALUES (553, '2007-09-13', 'teoria', 7, 12);
INSERT INTO egzaminy VALUES (554, '2007-09-20', 'praktyka', 19, 9);
INSERT INTO egzaminy VALUES (555, '2007-10-11', 'praktyka', 22, 10);
INSERT INTO egzaminy VALUES (556, '2007-11-01', 'praktyka', 16, 10);
INSERT INTO wyniki_egzaminów VALUES (1, 1, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (2, 1, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (3, 1, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (4, 2, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (5, 2, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (6, 2, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (7, 2, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (8, 3, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (9, 3, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (10, 4, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (11, 4, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (12, 4, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (13, 4, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (14, 4, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (15, 5, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (16, 5, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (17, 5, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (18, 5, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (19, 6, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (20, 6, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (21, 6, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (22, 6, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (23, 7, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (24, 7, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (25, 8, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (26, 8, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (27, 8, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (28, 8, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (29, 9, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (30, 9, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (31, 9, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (32, 9, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (33, 9, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (34, 10, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (35, 10, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (36, 11, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (37, 11, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (38, 11, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (39, 12, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (40, 12, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (41, 12, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (42, 12, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (43, 12, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (44, 13, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (45, 13, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (46, 13, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (47, 14, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (48, 14, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (49, 14, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (50, 15, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (51, 15, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (52, 15, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (53, 15, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (54, 15, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (55, 15, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (56, 16, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (57, 16, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (58, 16, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (59, 16, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (60, 17, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (61, 17, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (62, 17, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (63, 18, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (64, 18, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (65, 18, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (66, 18, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (67, 18, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (68, 18, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (69, 18, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (70, 18, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (71, 18, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (72, 18, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (73, 18, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (74, 18, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (75, 18, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (76, 18, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (77, 19, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (78, 19, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (79, 19, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (80, 19, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (81, 20, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (82, 20, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (83, 21, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (84, 21, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (85, 21, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (86, 22, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (87, 22, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (88, 22, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (89, 23, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (90, 23, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (91, 23, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (92, 23, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (93, 23, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (94, 23, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (95, 23, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (96, 23, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (97, 23, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (98, 23, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (99, 23, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (100, 23, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (101, 24, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (102, 24, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (103, 24, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (104, 24, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (105, 24, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (106, 25, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (107, 25, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (108, 25, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (109, 25, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (110, 26, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (111, 26, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (112, 26, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (113, 26, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (114, 26, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (115, 26, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (116, 26, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (117, 26, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (118, 26, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (119, 26, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (120, 27, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (121, 27, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (122, 27, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (123, 28, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (124, 28, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (125, 28, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (126, 28, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (127, 28, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (128, 28, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (129, 28, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (130, 29, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (131, 29, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (132, 29, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (133, 29, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (134, 30, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (135, 30, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (136, 30, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (137, 30, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (138, 30, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (139, 30, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (140, 30, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (141, 30, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (142, 31, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (143, 31, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (144, 31, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (145, 31, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (146, 32, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (147, 32, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (148, 32, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (149, 32, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (150, 33, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (151, 33, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (152, 33, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (153, 34, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (154, 34, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (155, 34, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (156, 34, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (157, 34, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (158, 34, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (159, 34, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (160, 34, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (161, 35, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (162, 35, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (163, 35, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (164, 35, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (165, 35, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (166, 35, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (167, 36, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (168, 36, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (169, 37, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (170, 37, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (171, 37, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (172, 37, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (173, 37, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (174, 37, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (175, 37, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (176, 37, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (177, 37, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (178, 37, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (179, 38, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (180, 38, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (181, 38, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (182, 38, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (183, 38, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (184, 38, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (185, 38, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (186, 39, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (187, 39, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (188, 39, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (189, 40, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (190, 40, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (191, 40, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (192, 41, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (193, 41, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (194, 41, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (195, 41, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (196, 41, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (197, 41, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (198, 41, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (199, 41, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (200, 41, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (201, 41, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (202, 41, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (203, 42, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (204, 42, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (205, 42, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (206, 42, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (103, 42, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (207, 43, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (208, 43, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (209, 43, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (210, 43, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (211, 44, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (212, 44, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (213, 44, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (214, 44, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (215, 45, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (216, 45, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (217, 45, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (218, 46, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (219, 46, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (220, 46, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (221, 46, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (222, 46, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (223, 46, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (224, 46, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (225, 46, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (226, 46, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (227, 46, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (228, 47, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (229, 47, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (230, 47, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (231, 47, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (232, 47, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (233, 48, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (234, 48, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (235, 48, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (236, 48, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (237, 48, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (238, 48, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (239, 48, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (240, 48, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (241, 49, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (242, 49, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (243, 49, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (244, 50, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (245, 50, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (246, 50, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (247, 50, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (248, 50, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (249, 50, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (250, 50, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (251, 50, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (252, 50, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (253, 50, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (254, 51, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (255, 51, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (256, 51, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (257, 51, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (258, 51, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (259, 51, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (260, 51, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (261, 51, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (262, 51, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (263, 51, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (264, 51, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (265, 51, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (266, 52, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (267, 52, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (268, 52, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (269, 52, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (270, 53, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (271, 53, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (272, 53, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (273, 54, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (274, 54, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (275, 55, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (276, 55, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (277, 55, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (278, 55, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (279, 55, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (280, 56, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (281, 56, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (282, 56, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (283, 56, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (284, 56, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (285, 56, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (286, 56, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (287, 56, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (288, 56, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (289, 56, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (290, 56, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (291, 56, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (292, 56, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (293, 57, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (294, 57, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (295, 57, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (296, 57, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (297, 58, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (298, 58, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (299, 58, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (300, 58, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (301, 58, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (302, 58, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (303, 58, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (304, 58, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (305, 58, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (306, 58, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (307, 58, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (308, 58, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (309, 58, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (310, 58, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (311, 58, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (312, 58, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (313, 59, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (314, 59, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (315, 59, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (316, 60, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (317, 60, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (318, 60, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (319, 60, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (320, 61, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (321, 61, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (322, 61, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (323, 61, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (324, 62, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (325, 62, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (326, 62, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (327, 62, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (328, 62, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (329, 62, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (330, 62, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (331, 62, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (332, 62, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (333, 62, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (334, 62, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (335, 62, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (336, 62, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (337, 62, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (338, 63, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (339, 63, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (340, 63, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (341, 63, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (342, 64, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (343, 64, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (344, 64, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (345, 64, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (346, 64, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (347, 64, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (348, 64, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (349, 65, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (350, 65, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (351, 65, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (352, 66, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (353, 66, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (354, 66, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (355, 66, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (356, 66, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (357, 66, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (358, 66, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (359, 66, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (360, 66, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (361, 66, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (362, 66, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (363, 66, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (364, 67, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (365, 67, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (366, 67, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (367, 67, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (368, 67, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (369, 67, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (370, 67, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (371, 67, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (372, 67, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (373, 67, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (374, 68, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (375, 68, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (376, 68, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (377, 69, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (378, 69, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (379, 69, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (380, 70, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (381, 70, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (382, 70, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (383, 70, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (384, 70, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (385, 70, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (386, 70, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (387, 70, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (388, 71, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (389, 71, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (390, 71, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (391, 71, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (392, 71, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (393, 71, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (394, 71, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (395, 71, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (396, 72, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (397, 72, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (398, 72, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (399, 72, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (400, 73, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (401, 73, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (402, 74, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (403, 74, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (404, 74, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (405, 75, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (406, 75, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (407, 75, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (408, 75, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (409, 75, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (410, 76, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (411, 76, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (412, 76, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (413, 76, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (414, 77, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (415, 77, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (416, 77, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (417, 78, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (418, 78, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (419, 78, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (420, 79, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (421, 79, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (422, 79, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (423, 80, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (424, 80, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (425, 80, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (426, 80, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (427, 80, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (428, 80, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (429, 80, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (430, 80, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (431, 80, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (432, 80, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (433, 80, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (434, 80, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (435, 80, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (436, 81, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (437, 81, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (438, 81, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (439, 81, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (440, 81, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (441, 82, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (442, 82, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (443, 82, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (444, 82, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (445, 83, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (446, 83, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (447, 83, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (448, 83, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (449, 83, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (450, 83, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (451, 83, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (452, 83, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (453, 84, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (454, 84, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (455, 84, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (456, 84, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (457, 84, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (458, 85, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (459, 85, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (460, 85, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (461, 85, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (462, 86, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (463, 86, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (464, 87, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (465, 87, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (466, 87, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (467, 87, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (468, 87, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (469, 87, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (470, 87, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (471, 87, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (472, 87, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (473, 87, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (61, 87, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (474, 87, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (475, 87, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (476, 88, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (477, 88, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (478, 88, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (479, 88, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (480, 88, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (481, 88, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (482, 88, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (483, 89, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (484, 89, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (485, 89, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (486, 90, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (487, 90, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (488, 90, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (489, 90, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (490, 90, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (491, 90, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (492, 90, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (493, 90, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (494, 91, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (495, 91, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (496, 91, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (497, 91, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (498, 91, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (499, 91, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (500, 92, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (501, 92, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (502, 92, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (503, 92, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (504, 92, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (505, 93, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (506, 93, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (507, 93, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (508, 94, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (509, 94, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (510, 94, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (511, 95, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (512, 95, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (513, 95, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (514, 95, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (515, 95, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (516, 95, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (517, 95, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (518, 95, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (519, 95, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (520, 95, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (235, 95, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (521, 95, 'nie stawił się');
INSERT INTO wyniki_egzaminów VALUES (233, 95, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (522, 95, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (523, 96, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (524, 96, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (525, 97, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (526, 97, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (527, 97, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (528, 97, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (529, 97, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (530, 97, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (531, 97, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (532, 97, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (533, 97, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (534, 98, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (535, 98, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (536, 98, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (537, 98, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (538, 98, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (539, 99, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (540, 99, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (541, 99, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (542, 99, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (543, 99, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (544, 100, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (545, 100, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (546, 100, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (547, 100, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (548, 100, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (549, 100, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (550, 100, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (551, 100, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (552, 100, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (553, 100, 'zdał');
INSERT INTO wyniki_egzaminów VALUES (554, 100, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (555, 100, 'nie zdał');
INSERT INTO wyniki_egzaminów VALUES (556, 100, 'zdał');
INSERT INTO prawa_jazdy VALUES ('53635/07/2827', 1, '2007-04-14', false);
INSERT INTO prawa_jazdy VALUES ('07892/10/7229', 2, '2010-02-10', false);
INSERT INTO prawa_jazdy VALUES ('50075/04/3003', 3, '2004-07-02', false);
INSERT INTO prawa_jazdy VALUES ('58536/10/0904', 4, '2010-01-16', false);
INSERT INTO prawa_jazdy VALUES ('90401/14/3242', 5, '2014-03-25', false);
INSERT INTO prawa_jazdy VALUES ('07436/08/2275', 6, '2008-05-19', false);
INSERT INTO prawa_jazdy VALUES ('54045/12/5800', 7, '2012-12-21', false);
INSERT INTO prawa_jazdy VALUES ('16199/10/5156', 8, '2010-01-13', false);
INSERT INTO prawa_jazdy VALUES ('36655/08/4998', 9, '2008-07-25', false);
INSERT INTO prawa_jazdy VALUES ('31083/10/7589', 10, '2010-09-10', false);
INSERT INTO prawa_jazdy VALUES ('94751/05/1430', 11, '2005-12-19', false);
INSERT INTO prawa_jazdy VALUES ('57581/04/6380', 12, '2004-11-09', false);
INSERT INTO prawa_jazdy VALUES ('59459/04/4318', 13, '2004-10-11', false);
INSERT INTO prawa_jazdy VALUES ('47971/15/9874', 14, '2015-03-22', false);
INSERT INTO prawa_jazdy VALUES ('61710/09/9898', 15, '2009-02-09', true);
INSERT INTO prawa_jazdy VALUES ('01342/09/1924', 15, '2009-01-19', true);
INSERT INTO prawa_jazdy VALUES ('45892/06/8462', 16, '2006-11-01', false);
INSERT INTO prawa_jazdy VALUES ('98020/08/5132', 17, '2008-06-12', false);
INSERT INTO prawa_jazdy VALUES ('50467/10/3767', 18, '2010-03-18', true);
INSERT INTO prawa_jazdy VALUES ('21423/10/1336', 18, '2010-04-08', true);
INSERT INTO prawa_jazdy VALUES ('12388/10/0811', 18, '2010-05-20', true);
INSERT INTO prawa_jazdy VALUES ('39902/10/2929', 18, '2010-06-10', true);
INSERT INTO prawa_jazdy VALUES ('19036/08/9140', 19, '2008-12-26', false);
INSERT INTO prawa_jazdy VALUES ('76062/11/9816', 20, '2011-07-27', false);
INSERT INTO prawa_jazdy VALUES ('01935/09/0806', 21, '2009-01-26', false);
INSERT INTO prawa_jazdy VALUES ('08067/07/2214', 22, '2007-04-30', false);
INSERT INTO prawa_jazdy VALUES ('29815/05/7829', 23, '2005-07-15', false);
INSERT INTO prawa_jazdy VALUES ('94341/05/5661', 23, '2005-07-15', false);
INSERT INTO prawa_jazdy VALUES ('17516/05/6124', 23, '2005-09-16', false);
INSERT INTO prawa_jazdy VALUES ('96561/07/7019', 24, '2007-09-22', true);
INSERT INTO prawa_jazdy VALUES ('81904/10/9067', 25, '2010-10-04', false);
INSERT INTO prawa_jazdy VALUES ('83095/11/5600', 26, '2011-07-08', false);
INSERT INTO prawa_jazdy VALUES ('35458/11/4223', 26, '2011-07-29', false);
INSERT INTO prawa_jazdy VALUES ('46658/11/3678', 26, '2011-09-09', false);
INSERT INTO prawa_jazdy VALUES ('17751/11/7594', 27, '2011-10-06', false);
INSERT INTO prawa_jazdy VALUES ('29947/04/8716', 28, '2004-09-18', true);
INSERT INTO prawa_jazdy VALUES ('75718/04/0779', 28, '2004-08-07', true);
INSERT INTO prawa_jazdy VALUES ('87316/05/4227', 29, '2005-06-10', false);
INSERT INTO prawa_jazdy VALUES ('11073/04/4073', 30, '2004-09-06', false);
INSERT INTO prawa_jazdy VALUES ('84305/04/3431', 30, '2004-09-27', false);
INSERT INTO prawa_jazdy VALUES ('63712/04/0748', 30, '2004-09-27', false);
INSERT INTO prawa_jazdy VALUES ('58143/13/5858', 31, '2013-11-23', false);
INSERT INTO prawa_jazdy VALUES ('29609/12/8585', 32, '2012-01-25', true);
INSERT INTO prawa_jazdy VALUES ('06579/09/7087', 33, '2009-06-24', false);
INSERT INTO prawa_jazdy VALUES ('69680/09/6334', 34, '2009-09-21', true);
INSERT INTO prawa_jazdy VALUES ('36772/09/4705', 34, '2009-10-12', true);
INSERT INTO prawa_jazdy VALUES ('55490/09/6866', 34, '2009-10-12', true);
INSERT INTO prawa_jazdy VALUES ('16550/05/1746', 35, '2005-04-11', true);
INSERT INTO prawa_jazdy VALUES ('59019/05/6567', 35, '2005-03-21', true);
INSERT INTO prawa_jazdy VALUES ('08717/09/2529', 36, '2009-12-20', false);
INSERT INTO prawa_jazdy VALUES ('41924/15/1461', 37, '2015-05-13', false);
INSERT INTO prawa_jazdy VALUES ('58359/15/5109', 37, '2015-05-13', false);
INSERT INTO prawa_jazdy VALUES ('71470/15/6470', 37, '2015-06-03', false);
INSERT INTO prawa_jazdy VALUES ('56135/09/3501', 38, '2009-09-08', true);
INSERT INTO prawa_jazdy VALUES ('99533/09/0824', 38, '2009-10-20', true);
INSERT INTO prawa_jazdy VALUES ('67688/14/0200', 39, '2014-04-30', false);
INSERT INTO prawa_jazdy VALUES ('52825/13/8410', 40, '2013-12-27', false);
INSERT INTO prawa_jazdy VALUES ('79090/13/2047', 41, '2013-10-14', false);
INSERT INTO prawa_jazdy VALUES ('97889/13/6724', 41, '2013-10-14', false);
INSERT INTO prawa_jazdy VALUES ('98279/13/0717', 41, '2013-09-23', false);
INSERT INTO prawa_jazdy VALUES ('37755/07/8279', 42, '2007-08-11', false);
INSERT INTO prawa_jazdy VALUES ('55331/05/9481', 43, '2005-03-18', false);
INSERT INTO prawa_jazdy VALUES ('65707/13/9727', 44, '2013-04-11', false);
INSERT INTO prawa_jazdy VALUES ('02933/12/9539', 45, '2012-07-23', false);
INSERT INTO prawa_jazdy VALUES ('39237/09/7180', 46, '2009-02-17', true);
INSERT INTO prawa_jazdy VALUES ('01263/09/9244', 46, '2009-04-21', true);
INSERT INTO prawa_jazdy VALUES ('60775/09/3886', 46, '2009-03-10', true);
INSERT INTO prawa_jazdy VALUES ('46838/14/8644', 47, '2014-07-13', false);
INSERT INTO prawa_jazdy VALUES ('26733/07/1699', 48, '2007-02-23', false);
INSERT INTO prawa_jazdy VALUES ('40456/07/5968', 48, '2007-02-02', false);
INSERT INTO prawa_jazdy VALUES ('88496/14/3120', 49, '2014-03-18', false);
INSERT INTO prawa_jazdy VALUES ('23275/12/1067', 50, '2012-12-07', false);
INSERT INTO prawa_jazdy VALUES ('07238/12/8832', 50, '2012-12-28', false);
INSERT INTO prawa_jazdy VALUES ('52429/04/5184', 51, '2004-12-19', true);
INSERT INTO prawa_jazdy VALUES ('67961/05/1684', 51, '2005-01-09', true);
INSERT INTO prawa_jazdy VALUES ('98521/04/5502', 51, '2004-12-19', true);
INSERT INTO prawa_jazdy VALUES ('09590/05/2744', 51, '2005-01-09', true);
INSERT INTO prawa_jazdy VALUES ('49005/15/0973', 52, '2015-05-20', false);
INSERT INTO prawa_jazdy VALUES ('62159/11/3530', 53, '2011-04-30', false);
INSERT INTO prawa_jazdy VALUES ('42321/10/6722', 54, '2010-04-20', false);
INSERT INTO prawa_jazdy VALUES ('33611/04/8606', 55, '2004-07-17', false);
INSERT INTO prawa_jazdy VALUES ('48333/08/0871', 56, '2008-07-20', true);
INSERT INTO prawa_jazdy VALUES ('28409/08/1165', 56, '2008-09-21', true);
INSERT INTO prawa_jazdy VALUES ('94936/08/9577', 56, '2008-09-21', true);
INSERT INTO prawa_jazdy VALUES ('64670/08/3161', 56, '2008-11-02', true);
INSERT INTO prawa_jazdy VALUES ('98827/14/3531', 57, '2014-12-30', false);
INSERT INTO prawa_jazdy VALUES ('51398/15/7633', 57, '2015-01-20', false);
INSERT INTO prawa_jazdy VALUES ('28708/09/1020', 58, '2009-06-01', false);
INSERT INTO prawa_jazdy VALUES ('36353/09/1797', 58, '2009-07-13', false);
INSERT INTO prawa_jazdy VALUES ('95182/09/3921', 58, '2009-07-13', false);
INSERT INTO prawa_jazdy VALUES ('48715/09/4210', 58, '2009-07-13', false);
INSERT INTO prawa_jazdy VALUES ('11297/12/8754', 59, '2012-01-10', false);
INSERT INTO prawa_jazdy VALUES ('21432/14/4560', 60, '2014-03-15', true);
INSERT INTO prawa_jazdy VALUES ('87953/07/3022', 61, '2007-06-24', false);
INSERT INTO prawa_jazdy VALUES ('95545/06/7188', 62, '2006-02-04', false);
INSERT INTO prawa_jazdy VALUES ('28285/06/1312', 62, '2006-02-04', false);
INSERT INTO prawa_jazdy VALUES ('75402/06/2086', 62, '2006-03-18', false);
INSERT INTO prawa_jazdy VALUES ('72451/05/2783', 63, '2005-10-16', false);
INSERT INTO prawa_jazdy VALUES ('56557/05/7973', 63, '2005-11-06', false);
INSERT INTO prawa_jazdy VALUES ('10859/14/0110', 64, '2014-11-01', true);
INSERT INTO prawa_jazdy VALUES ('51645/15/8402', 64, '2015-01-24', true);
INSERT INTO prawa_jazdy VALUES ('55263/10/4834', 65, '2010-12-05', false);
INSERT INTO prawa_jazdy VALUES ('16125/10/7503', 66, '2010-01-18', true);
INSERT INTO prawa_jazdy VALUES ('54133/10/1970', 66, '2010-02-08', true);
INSERT INTO prawa_jazdy VALUES ('03109/10/8649', 66, '2010-03-01', true);
INSERT INTO prawa_jazdy VALUES ('62496/10/6601', 67, '2010-08-31', false);
INSERT INTO prawa_jazdy VALUES ('59756/10/7542', 67, '2010-09-21', false);
INSERT INTO prawa_jazdy VALUES ('54545/10/9176', 68, '2010-02-06', true);
INSERT INTO prawa_jazdy VALUES ('12275/11/4511', 69, '2011-05-18', false);
INSERT INTO prawa_jazdy VALUES ('43868/07/2431', 70, '2007-05-28', true);
INSERT INTO prawa_jazdy VALUES ('95233/07/3006', 70, '2007-05-07', true);
INSERT INTO prawa_jazdy VALUES ('13833/13/7519', 71, '2013-09-16', true);
INSERT INTO prawa_jazdy VALUES ('49491/13/4169', 71, '2013-11-18', true);
INSERT INTO prawa_jazdy VALUES ('33620/04/9644', 72, '2004-06-28', true);
INSERT INTO prawa_jazdy VALUES ('77170/05/0449', 73, '2005-12-10', false);
INSERT INTO prawa_jazdy VALUES ('74593/05/2886', 74, '2005-10-01', false);
INSERT INTO prawa_jazdy VALUES ('71358/14/1740', 75, '2014-12-10', false);
INSERT INTO prawa_jazdy VALUES ('46304/11/4501', 76, '2011-06-23', false);
INSERT INTO prawa_jazdy VALUES ('68204/07/6405', 77, '2007-09-28', false);
INSERT INTO prawa_jazdy VALUES ('75722/07/5811', 78, '2007-03-08', false);
INSERT INTO prawa_jazdy VALUES ('95319/08/8166', 79, '2008-11-09', true);
INSERT INTO prawa_jazdy VALUES ('29337/13/8160', 80, '2013-09-14', true);
INSERT INTO prawa_jazdy VALUES ('16933/13/2565', 80, '2013-10-26', true);
INSERT INTO prawa_jazdy VALUES ('16511/13/2032', 80, '2013-11-16', true);
INSERT INTO prawa_jazdy VALUES ('90844/13/0318', 80, '2013-10-26', true);
INSERT INTO prawa_jazdy VALUES ('39128/13/7600', 81, '2013-08-26', false);
INSERT INTO prawa_jazdy VALUES ('46379/11/9653', 82, '2011-07-17', false);
INSERT INTO prawa_jazdy VALUES ('57571/04/7889', 83, '2004-12-13', false);
INSERT INTO prawa_jazdy VALUES ('39802/05/8077', 83, '2005-01-03', false);
INSERT INTO prawa_jazdy VALUES ('68031/09/3447', 84, '2009-03-06', true);
INSERT INTO prawa_jazdy VALUES ('54165/11/9271', 85, '2011-12-30', false);
INSERT INTO prawa_jazdy VALUES ('23104/10/5230', 86, '2010-01-15', false);
INSERT INTO prawa_jazdy VALUES ('68668/08/9848', 87, '2008-04-10', false);
INSERT INTO prawa_jazdy VALUES ('76773/08/5760', 87, '2008-04-10', false);
INSERT INTO prawa_jazdy VALUES ('84002/08/4760', 87, '2008-05-22', false);
INSERT INTO prawa_jazdy VALUES ('56498/08/6773', 87, '2008-05-01', false);
INSERT INTO prawa_jazdy VALUES ('23210/15/8128', 88, '2015-04-04', false);
INSERT INTO prawa_jazdy VALUES ('75594/15/7117', 88, '2015-05-16', false);
INSERT INTO prawa_jazdy VALUES ('33716/13/3864', 89, '2013-01-14', false);
INSERT INTO prawa_jazdy VALUES ('24659/11/3195', 90, '2011-01-09', false);
INSERT INTO prawa_jazdy VALUES ('37475/10/6139', 90, '2010-12-19', false);
INSERT INTO prawa_jazdy VALUES ('17864/04/0059', 91, '2004-05-24', true);
INSERT INTO prawa_jazdy VALUES ('25544/04/4141', 91, '2004-06-14', true);
INSERT INTO prawa_jazdy VALUES ('75845/13/2054', 92, '2013-07-09', false);
INSERT INTO prawa_jazdy VALUES ('06891/05/9714', 93, '2005-06-29', false);
INSERT INTO prawa_jazdy VALUES ('40699/09/0810', 94, '2009-11-03', false);
INSERT INTO prawa_jazdy VALUES ('77629/06/6736', 95, '2006-10-20', true);
INSERT INTO prawa_jazdy VALUES ('46900/06/6863', 95, '2006-11-10', true);
INSERT INTO prawa_jazdy VALUES ('83186/07/1836', 95, '2007-01-12', true);
INSERT INTO prawa_jazdy VALUES ('87435/06/2471', 95, '2006-12-22', true);
INSERT INTO prawa_jazdy VALUES ('60883/11/9258', 96, '2011-01-31', false);
INSERT INTO prawa_jazdy VALUES ('05838/06/7984', 97, '2006-07-03', true);
INSERT INTO prawa_jazdy VALUES ('96814/06/6649', 97, '2006-06-12', true);
INSERT INTO prawa_jazdy VALUES ('55719/06/7695', 97, '2006-07-24', true);
INSERT INTO prawa_jazdy VALUES ('03896/09/7405', 98, '2009-01-07', false);
INSERT INTO prawa_jazdy VALUES ('80923/14/7243', 99, '2014-10-20', false);
INSERT INTO prawa_jazdy VALUES ('16396/07/3010', 100, '2007-09-08', true);
INSERT INTO prawa_jazdy VALUES ('91556/07/8018', 100, '2007-10-20', true);
INSERT INTO prawa_jazdy VALUES ('77585/07/0146', 100, '2007-09-29', true);
INSERT INTO prawa_jazdy VALUES ('34352/07/1666', 100, '2007-12-01', true);
INSERT INTO prawa_jazdy_kategorie VALUES ('53635/07/2827', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('07892/10/7229', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('50075/04/3003', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('58536/10/0904', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('90401/14/3242', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('07436/08/2275', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('54045/12/5800', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('16199/10/5156', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('36655/08/4998', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('31083/10/7589', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('94751/05/1430', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('57581/04/6380', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('59459/04/4318', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('47971/15/9874', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('61710/09/9898', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('01342/09/1924', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('45892/06/8462', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('98020/08/5132', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('50467/10/3767', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('21423/10/1336', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('12388/10/0811', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('39902/10/2929', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('19036/08/9140', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('76062/11/9816', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('01935/09/0806', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('08067/07/2214', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('29815/05/7829', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('94341/05/5661', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('17516/05/6124', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('96561/07/7019', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('81904/10/9067', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('83095/11/5600', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('35458/11/4223', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('46658/11/3678', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('17751/11/7594', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('29947/04/8716', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('75718/04/0779', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('87316/05/4227', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('11073/04/4073', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('84305/04/3431', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('63712/04/0748', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('58143/13/5858', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('29609/12/8585', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('06579/09/7087', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('69680/09/6334', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('36772/09/4705', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('55490/09/6866', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('16550/05/1746', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('59019/05/6567', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('08717/09/2529', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('41924/15/1461', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('58359/15/5109', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('71470/15/6470', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('56135/09/3501', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('99533/09/0824', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('67688/14/0200', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('52825/13/8410', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('79090/13/2047', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('97889/13/6724', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('98279/13/0717', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('37755/07/8279', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('55331/05/9481', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('65707/13/9727', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('02933/12/9539', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('39237/09/7180', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('01263/09/9244', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('60775/09/3886', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('46838/14/8644', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('26733/07/1699', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('40456/07/5968', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('88496/14/3120', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('23275/12/1067', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('07238/12/8832', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('52429/04/5184', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('67961/05/1684', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('98521/04/5502', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('09590/05/2744', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('49005/15/0973', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('62159/11/3530', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('42321/10/6722', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('33611/04/8606', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('48333/08/0871', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('28409/08/1165', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('94936/08/9577', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('64670/08/3161', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('98827/14/3531', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('51398/15/7633', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('28708/09/1020', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('36353/09/1797', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('95182/09/3921', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('48715/09/4210', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('11297/12/8754', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('21432/14/4560', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('87953/07/3022', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('95545/06/7188', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('28285/06/1312', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('75402/06/2086', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('72451/05/2783', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('56557/05/7973', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('10859/14/0110', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('51645/15/8402', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('55263/10/4834', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('16125/10/7503', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('54133/10/1970', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('03109/10/8649', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('62496/10/6601', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('59756/10/7542', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('54545/10/9176', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('12275/11/4511', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('43868/07/2431', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('95233/07/3006', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('13833/13/7519', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('49491/13/4169', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('33620/04/9644', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('77170/05/0449', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('74593/05/2886', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('71358/14/1740', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('46304/11/4501', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('68204/07/6405', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('75722/07/5811', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('95319/08/8166', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('29337/13/8160', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('16933/13/2565', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('16511/13/2032', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('90844/13/0318', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('39128/13/7600', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('46379/11/9653', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('57571/04/7889', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('39802/05/8077', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('68031/09/3447', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('54165/11/9271', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('23104/10/5230', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('68668/08/9848', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('76773/08/5760', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('84002/08/4760', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('56498/08/6773', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('23210/15/8128', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('75594/15/7117', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('33716/13/3864', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('24659/11/3195', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('37475/10/6139', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('17864/04/0059', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('25544/04/4141', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('75845/13/2054', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('06891/05/9714', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('40699/09/0810', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('77629/06/6736', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('46900/06/6863', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('83186/07/1836', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('87435/06/2471', 'D');
INSERT INTO prawa_jazdy_kategorie VALUES ('60883/11/9258', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('05838/06/7984', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('96814/06/6649', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('55719/06/7695', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('03896/09/7405', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('80923/14/7243', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('16396/07/3010', 'B');
INSERT INTO prawa_jazdy_kategorie VALUES ('91556/07/8018', 'A');
INSERT INTO prawa_jazdy_kategorie VALUES ('77585/07/0146', 'C');
INSERT INTO prawa_jazdy_kategorie VALUES ('34352/07/1666', 'D');
INSERT INTO pojazdy VALUES (1, 'CBY 1WG', '2010-01-02', 'chrysler', 'neon', 'osobowy');
INSERT INTO pojazdy VALUES (2, 'CMG 078', '2014-10-31', 'nissan', '350-z', 'osobowy');
INSERT INTO pojazdy VALUES (3, 'SMI 81V', '2012-12-25', 'daihatsu', 'rocky', 'osobowy');
INSERT INTO pojazdy VALUES (4, 'CB 228X', '2010-07-22', 'lada', '2111', 'osobowy');
INSERT INTO pojazdy VALUES (5, 'TK 9CB9', '2008-03-23', 'peugeot', '308-cc', 'osobowy');
INSERT INTO pojazdy VALUES (6, 'NNI 1N6', '2009-08-23', 'rover', 'city-rover', 'osobowy');
INSERT INTO pojazdy VALUES (7, 'ZGY 1ZU', '2014-10-11', 'subaru', 'leone', 'osobowy');
INSERT INTO pojazdy VALUES (8, 'RBI 0Y4', '2012-06-09', 'mercury', 'villager', 'osobowy');
INSERT INTO pojazdy VALUES (9, 'WPL 5UD', '2015-06-04', 'chevrolet', '2500', 'osobowy');
INSERT INTO pojazdy VALUES (10, 'WML 62S', '2014-08-23', 'aston-martin', 'vanquish', 'osobowy');
INSERT INTO pojazdy VALUES (11, 'RPZ 878', '2012-04-18', 'maserati', 'grancabrio', 'osobowy');
INSERT INTO pojazdy VALUES (12, 'CRY 2DF', '2009-01-14', 'bentley', 'arnage', 'osobowy');
INSERT INTO pojazdy VALUES (13, 'ERA 9DF', '2015-06-05', 'rolls-royce', 'phantom', 'osobowy');
INSERT INTO pojazdy VALUES (14, 'TBU 27D', '2013-08-25', 'skoda', 'praktik', 'ciężarowy');
INSERT INTO pojazdy VALUES (15, 'NBA 04L', '2012-09-02', 'pontiac', 'montana', 'osobowy');
INSERT INTO pojazdy VALUES (16, 'RJS 27E', '2008-01-04', 'peugeot', '4007', 'osobowy');
INSERT INTO pojazdy VALUES (17, 'SPI 03D', '2007-09-05', 'lexus', 'hs-250h', 'osobowy');
INSERT INTO pojazdy VALUES (18, 'SK 894D', '2014-07-03', 'plymouth', 'turismo', 'osobowy');
INSERT INTO pojazdy VALUES (19, 'SMI 221', '2011-10-31', 'opel', 'movano', 'osobowy');
INSERT INTO pojazdy VALUES (20, 'WOT 9JJ', '2015-07-24', 'chevrolet', 'chevelle', 'osobowy');
INSERT INTO pojazdy VALUES (21, 'DKA 3E4', '2014-11-05', 'alfa-romeo', 'giulia', 'osobowy');
INSERT INTO pojazdy VALUES (22, 'PZL 333', '2008-12-31', 'ferrari', 'f50', 'osobowy');
INSERT INTO pojazdy VALUES (23, 'ZSD 4W1', '2009-08-23', 'mitsubishi', 'eclipse', 'osobowy');
INSERT INTO pojazdy VALUES (24, 'GWE 066', '2012-02-15', 'maserati', 'karif', 'osobowy');
INSERT INTO pojazdy VALUES (25, 'ZWA 0BQ', '2016-04-25', 'volkswagen', 'golf-sportsvan', 'osobowy');
INSERT INTO pojazdy VALUES (26, 'RSR 7XE', '2013-08-09', 'peugeot', '2008', 'osobowy');
INSERT INTO pojazdy VALUES (27, 'PCT 3DE', '2016-03-15', 'mazda', 'seria-e', 'osobowy');
INSERT INTO pojazdy VALUES (28, 'OST 5QR', '2013-10-02', 'mercedes-benz', 'w124-1984-1993', 'osobowy');
INSERT INTO pojazdy VALUES (29, 'KCH 2DV', '2010-03-26', 'pontiac', 'catalina', 'osobowy');
INSERT INTO pojazdy VALUES (30, 'KPR 463', '2011-06-25', 'citroen', 'c1', 'osobowy');
INSERT INTO pojazdy VALUES (31, 'KNS 936', '2014-07-01', 'lancia', 'beta', 'osobowy');
INSERT INTO pojazdy VALUES (32, 'SC 5AK5', '2011-08-22', 'hummer', 'h3', 'osobowy');
INSERT INTO pojazdy VALUES (33, 'SR 5821', '2007-03-09', 'land-rover', 'defender', 'osobowy');
INSERT INTO pojazdy VALUES (34, 'BGR 38H', '2008-10-16', 'porsche', '911', 'osobowy');
INSERT INTO pojazdy VALUES (35, 'EP 3TP3', '2009-05-14', 'honda', 'logo', 'osobowy');
INSERT INTO pojazdy VALUES (36, 'PSL 4RP', '2014-05-24', 'alfa-romeo', 'spider', 'ciężarowy');
INSERT INTO pojazdy VALUES (37, 'WOS 8DN', '2011-10-23', 'hyundai', 'avante', 'osobowy');
INSERT INTO pojazdy VALUES (38, 'KLI 6XZ', '2015-01-01', 'chevrolet', 'trailblazer', 'osobowy');
INSERT INTO pojazdy VALUES (39, 'SZY 899', '2012-08-12', 'daihatsu', 'cuore', 'osobowy');
INSERT INTO pojazdy VALUES (40, 'ESI 09L', '2014-10-25', 'chevrolet', 'c-30', 'osobowy');
INSERT INTO pojazdy VALUES (41, 'PSR 37L', '2011-10-24', 'kia', 'sportage', 'osobowy');
INSERT INTO pojazdy VALUES (42, 'PWA 26A', '2009-11-30', 'bmw', 'seria-4', 'osobowy');
INSERT INTO pojazdy VALUES (43, 'DBA 94T', '2007-01-19', 'volvo', 'xc-60', 'osobowy');
INSERT INTO pojazdy VALUES (44, 'WND 91I', '2015-04-20', 'saab', '9-7x', 'osobowy');
INSERT INTO pojazdy VALUES (45, 'PSR 47V', '2014-09-30', 'ford', 'mustang', 'osobowy');
INSERT INTO pojazdy VALUES (46, 'SZ 56UT', '2016-03-05', 'ford', 'grand c-max', 'osobowy');
INSERT INTO pojazdy VALUES (47, 'TKN 9SB', '2013-08-16', 'fiat', 'ducato', 'osobowy');
INSERT INTO pojazdy VALUES (48, 'SI 1X51', '2015-02-02', 'lancia', 'voyager', 'osobowy');
INSERT INTO pojazdy VALUES (49, 'SZY 862', '2012-06-10', 'mercury', 'montego', 'osobowy');
INSERT INTO pojazdy VALUES (50, 'KLI 3VY', '2013-06-12', 'dodge', 'challenger', 'osobowy');
INSERT INTO pojazdy VALUES (51, 'ONA 45E', '2016-04-24', 'chevrolet', 'lumina', 'osobowy');
INSERT INTO pojazdy VALUES (52, 'WM 1C0P', '2012-02-29', 'fiat', 'fiorino', 'osobowy');
INSERT INTO pojazdy VALUES (53, 'FSL 788', '2007-11-12', 'toyota', 'highlander', 'osobowy');
INSERT INTO pojazdy VALUES (54, 'WO 6JG6', '2014-09-25', 'aston-martin', 'v8-vantage', 'osobowy');
INSERT INTO pojazdy VALUES (55, 'ZMY 8U3', '2010-05-28', 'mini', 'clubman', 'osobowy');
INSERT INTO pojazdy VALUES (56, 'ESI 7H8', '2015-01-13', 'dodge', 'nitro', 'osobowy');
INSERT INTO pojazdy VALUES (57, 'SPI 47Y', '2015-09-03', 'lexus', 'lx', 'osobowy');
INSERT INTO pojazdy VALUES (58, 'KNS 1JB', '2016-02-08', 'nissan', 'titan', 'osobowy');
INSERT INTO pojazdy VALUES (59, 'LLU 4RL', '2015-12-11', 'lincoln', 'mkx', 'osobowy');
INSERT INTO pojazdy VALUES (60, 'KBR 2ZU', '2015-07-28', 'ford', 'festiva', 'osobowy');
INSERT INTO pojazdy VALUES (61, 'EL 3WF2', '2016-03-02', 'subaru', 'tribeca', 'osobowy');
INSERT INTO pojazdy VALUES (62, 'NPI 17B', '2008-12-13', 'dodge', 'nitro', 'osobowy');
INSERT INTO pojazdy VALUES (63, 'SZ 8SU8', '2016-03-08', 'audi', 'q5', 'osobowy');
INSERT INTO pojazdy VALUES (64, 'BGR 6Q4', '2013-03-24', 'hyundai', 'accent', 'osobowy');
INSERT INTO pojazdy VALUES (65, 'OOL 2M5', '2013-10-01', 'mitsubishi', 'outlander', 'ciężarowy');
INSERT INTO pojazdy VALUES (66, 'WOT 364', '2012-03-03', 'peugeot', '604', 'osobowy');
INSERT INTO pojazdy VALUES (67, 'GSP 9O5', '2015-01-20', 'fiat', 'bravo', 'osobowy');
INSERT INTO pojazdy VALUES (68, 'PJA 4K8', '2011-07-28', 'syrena', '101', 'osobowy');
INSERT INTO pojazdy VALUES (69, 'SM 427M', '2006-11-13', 'mazda', 'mx-6', 'osobowy');
INSERT INTO pojazdy VALUES (70, 'WLS 1XT', '2014-08-18', 'rolls-royce', 'ghost', 'osobowy');
INSERT INTO pojazdy VALUES (71, 'GWE 47I', '2016-02-23', 'toyota', 'crown', 'osobowy');
INSERT INTO pojazdy VALUES (72, 'KNT 0A4', '2007-01-17', 'mitsubishi', 'santamo', 'osobowy');
INSERT INTO pojazdy VALUES (73, 'DWR 844', '2015-08-31', 'rover', 'mg', 'osobowy');
INSERT INTO pojazdy VALUES (74, 'ETM 2C4', '2016-04-13', 'vauxhall', 'frontera', 'osobowy');
INSERT INTO pojazdy VALUES (75, 'RSR 717', '2015-02-08', 'peugeot', '306', 'osobowy');
INSERT INTO pojazdy VALUES (76, 'DMI 4AO', '2011-05-30', 'seat', 'terra', 'osobowy');
INSERT INTO pojazdy VALUES (77, 'KMY 6MI', '2016-03-28', 'volvo', '944', 'osobowy');
INSERT INTO pojazdy VALUES (78, 'WBR 3I0', '2007-07-12', 'proton', 'seria-400', 'osobowy');
INSERT INTO pojazdy VALUES (79, 'SW 9I8P', '2009-07-28', 'lada', '2110', 'osobowy');
INSERT INTO pojazdy VALUES (80, 'SZO 645', '2015-09-11', 'mazda', '626', 'osobowy');
INSERT INTO pojazdy VALUES (81, 'CZN 1LF', '2015-08-12', 'mercedes-benz', 'mb-100', 'osobowy');
INSERT INTO pojazdy VALUES (82, 'SKL 4E4', '2014-01-06', 'dodge', 'diplomat', 'osobowy');
INSERT INTO pojazdy VALUES (83, 'FGW 06N', '2014-11-18', 'alfa-romeo', '33', 'osobowy');
INSERT INTO pojazdy VALUES (84, 'GPU 3VK', '2013-07-02', 'rolls-royce', 'ghost', 'osobowy');
INSERT INTO pojazdy VALUES (85, 'ZMY 6GX', '2016-03-27', 'hummer', 'h3', 'osobowy');
INSERT INTO pojazdy VALUES (86, 'SM 5M27', '2015-09-08', 'polonez', 'caro', 'osobowy');
INSERT INTO pojazdy VALUES (87, 'STA 533', '2015-11-27', 'chrysler', 'neon', 'osobowy');
INSERT INTO pojazdy VALUES (88, 'LCH 6B2', '2013-12-06', 'renault', '5', 'osobowy');
INSERT INTO pojazdy VALUES (89, 'LTM 2DX', '2014-03-11', 'toyota', 'paseo', 'osobowy');
INSERT INTO pojazdy VALUES (90, 'LCH 379', '2009-11-26', 'peugeot', '407', 'osobowy');
INSERT INTO pojazdy VALUES (91, 'RJA 22B', '2015-04-21', 'infiniti', 'g', 'osobowy');
INSERT INTO pojazdy VALUES (92, 'WSI 7NO', '2013-10-06', 'mazda', 'rx-8', 'osobowy');
INSERT INTO pojazdy VALUES (93, 'CGR 487', '2014-12-26', 'suzuki', 'swift', 'osobowy');
INSERT INTO pojazdy VALUES (94, 'SD 7RT2', '2015-12-09', 'chevrolet', 'camaro', 'osobowy');
INSERT INTO pojazdy VALUES (95, 'DJ 06LY', '2012-06-08', 'plymouth', 'prowler', 'osobowy');
INSERT INTO pojazdy VALUES (96, 'PZL 941', '2015-02-09', 'ferrari', 'mondial', 'osobowy');
INSERT INTO pojazdy VALUES (97, 'NO 64PC', '2011-11-26', 'ferrari', '365', 'osobowy');
INSERT INTO pojazdy VALUES (98, 'EWE 9QM', '2013-07-19', 'plymouth', 'superbird', 'osobowy');
INSERT INTO pojazdy VALUES (99, 'GCZ 105', '2012-01-18', 'rolls-royce', 'silver-cloud', 'osobowy');
INSERT INTO pojazdy VALUES (100, 'CTU 331', '2016-01-06', 'ford', 'contour', 'osobowy');
INSERT INTO pojazdy VALUES (101, 'WSK 4KK', '2016-01-31', 'chevrolet', 'colorado', 'osobowy');
INSERT INTO pojazdy VALUES (102, 'LOP 4Z3', '2015-11-16', 'kia', 'mentor', 'osobowy');
INSERT INTO pojazdy VALUES (103, 'CIN 130', '2011-02-02', 'lamborghini', 'diablo', 'osobowy');
INSERT INTO pojazdy VALUES (104, 'DMI 55S', '2010-06-05', 'toyota', 'land-cruiser', 'osobowy');
INSERT INTO pojazdy VALUES (105, 'WSE 621', '2015-09-27', 'wartburg', '311', 'osobowy');
INSERT INTO pojazdy VALUES (106, 'PTU 7OR', '2010-06-11', 'audi', '200', 'osobowy');
INSERT INTO pojazdy VALUES (107, 'ZKO 7Y7', '2013-04-14', 'subaru', 'outback', 'osobowy');
INSERT INTO pojazdy VALUES (108, 'DGR 38A', '2010-10-02', 'aixam', 'a721', 'osobowy');
INSERT INTO pojazdy VALUES (109, 'TJE 9M1', '2009-10-28', 'ligier', 'nova', 'osobowy');
INSERT INTO pojazdy VALUES (110, 'CBR 95H', '2014-02-28', 'acura', 'cl', 'osobowy');
INSERT INTO pojazdy VALUES (111, 'SW 04I3', '2016-04-13', 'chevrolet', 's-10', 'osobowy');
INSERT INTO pojazdy VALUES (112, 'LZ 8WR7', '2015-12-22', 'triumph', 'moss', 'osobowy');
INSERT INTO pojazdy VALUES (113, 'ZPL 8C8', '2014-08-02', 'chrysler', 'saratoga', 'osobowy');
INSERT INTO pojazdy VALUES (114, 'CB 2077', '2012-06-11', 'toyota', 'avensis', 'osobowy');
INSERT INTO pojazdy VALUES (115, 'DPL 8RD', '2015-07-12', 'ferrari', '750', 'osobowy');
INSERT INTO pojazdy VALUES (116, 'ZSL 2T2', '2007-02-04', 'chevrolet', 'impala', 'osobowy');
INSERT INTO pojazdy VALUES (117, 'ELC 2O3', '2012-02-13', 'mercedes-benz', 'vito', 'osobowy');
INSERT INTO pojazdy VALUES (118, 'CTR 8KG', '2015-12-14', 'hyundai', 'coupe', 'osobowy');
INSERT INTO pojazdy VALUES (119, 'RZ 710A', '2013-07-04', 'saab', '9-3', 'osobowy');
INSERT INTO pojazdy VALUES (120, 'DLE 361', '2013-05-24', 'chevrolet', 'lumina', 'osobowy');
INSERT INTO pojazdy VALUES (121, 'PKA 6JI', '2013-06-10', 'aston-martin', 'virage', 'osobowy');
INSERT INTO pojazdy VALUES (122, 'SMY 1QA', '2016-04-14', 'suzuki', 'liana', 'osobowy');
INSERT INTO pojazdy VALUES (123, 'PWL 63I', '2014-04-22', 'aro', 'seria-320', 'osobowy');
INSERT INTO pojazdy VALUES (124, 'OST 7L1', '2012-04-26', 'lotus', 'esprit', 'osobowy');
INSERT INTO pojazdy VALUES (125, 'POZ 4SJ', '2005-03-07', 'dodge', 'stratus', 'osobowy');
INSERT INTO pojazdy VALUES (126, 'RJS 827', '2013-06-12', 'chrysler', 'stratus', 'osobowy');
INSERT INTO pojazdy VALUES (127, 'KTA 853', '2010-11-21', 'toyota', 'verso', 'osobowy');
INSERT INTO pojazdy VALUES (128, 'WS 4W6J', '2013-03-07', 'maserati', '224', 'osobowy');
INSERT INTO pojazdy VALUES (129, 'NOL 6B5', '2016-03-24', 'aixam', 'scouty-r', 'osobowy');
INSERT INTO pojazdy VALUES (130, 'EBE 7K0', '2010-11-02', 'nissan', 'patrol', 'osobowy');
INSERT INTO pojazdy VALUES (131, 'LSW 33H', '2016-04-19', 'opel', 'senator', 'osobowy');
INSERT INTO pojazdy VALUES (132, 'GSP 338', '2014-01-26', 'nissan', 'quest', 'osobowy');
INSERT INTO pojazdy VALUES (133, 'LU 8R3D', '2014-05-16', 'chrysler', 'sebring', 'osobowy');
INSERT INTO pojazdy VALUES (134, 'NDZ 99U', '2011-04-07', 'chrysler', 'stratus', 'osobowy');
INSERT INTO pojazdy VALUES (135, 'KDA 7J7', '2004-06-25', 'bentley', 'brooklands', 'osobowy');
INSERT INTO pojazdy VALUES (136, 'SR 8B5K', '2010-01-22', 'aixam', 'a741', 'osobowy');
INSERT INTO pojazdy VALUES (137, 'DWR 6W4', '2013-08-19', 'acura', 'vigor', 'osobowy');
INSERT INTO pojazdy VALUES (138, 'WOR 1V6', '2009-04-08', 'lincoln', 'ls', 'osobowy');
INSERT INTO pojazdy VALUES (139, 'STY 070', '2009-01-30', 'mercedes-benz', '350', 'osobowy');
INSERT INTO pojazdy VALUES (140, 'WCI 3U4', '2014-10-07', 'ford', 'probe', 'osobowy');
INSERT INTO pojazdy VALUES (141, 'RK 77X3', '2014-11-22', 'ford', 'ranger', 'osobowy');
INSERT INTO pojazdy VALUES (142, 'ZST 07H', '2007-06-16', 'ferrari', 'superamerica', 'osobowy');
INSERT INTO pojazdy VALUES (143, 'PKR 8G1', '2011-12-09', 'lada', '2110', 'osobowy');
INSERT INTO pojazdy VALUES (144, 'LOP 03Y', '2015-07-10', 'skoda', 'favorit', 'osobowy');
INSERT INTO pojazdy VALUES (145, 'WLS 6IK', '2010-06-27', 'kia', 'venga', 'osobowy');
INSERT INTO pojazdy VALUES (146, 'FSW 0LL', '2013-05-21', 'cadillac', 'cts', 'osobowy');
INSERT INTO pojazdy VALUES (147, 'LOP 3K3', '2011-03-27', 'peugeot', '605', 'osobowy');
INSERT INTO pojazdy VALUES (148, 'LJA 35X', '2015-12-24', 'mitsubishi', 'galloper', 'osobowy');
INSERT INTO pojazdy VALUES (149, 'NKE 30W', '2008-11-15', 'fiat', 'brava', 'osobowy');
INSERT INTO kierowcy_pojazdy VALUES (1, 1);
INSERT INTO kierowcy_pojazdy VALUES (2, 2);
INSERT INTO kierowcy_pojazdy VALUES (2, 3);
INSERT INTO kierowcy_pojazdy VALUES (3, 4);
INSERT INTO kierowcy_pojazdy VALUES (3, 5);
INSERT INTO kierowcy_pojazdy VALUES (4, 6);
INSERT INTO kierowcy_pojazdy VALUES (5, 7);
INSERT INTO kierowcy_pojazdy VALUES (6, 8);
INSERT INTO kierowcy_pojazdy VALUES (7, 9);
INSERT INTO kierowcy_pojazdy VALUES (7, 10);
INSERT INTO kierowcy_pojazdy VALUES (8, 11);
INSERT INTO kierowcy_pojazdy VALUES (9, 12);
INSERT INTO kierowcy_pojazdy VALUES (9, 13);
INSERT INTO kierowcy_pojazdy VALUES (10, 14);
INSERT INTO kierowcy_pojazdy VALUES (10, 15);
INSERT INTO kierowcy_pojazdy VALUES (11, 16);
INSERT INTO kierowcy_pojazdy VALUES (12, 17);
INSERT INTO kierowcy_pojazdy VALUES (12, 18);
INSERT INTO kierowcy_pojazdy VALUES (13, 19);
INSERT INTO kierowcy_pojazdy VALUES (14, 20);
INSERT INTO kierowcy_pojazdy VALUES (14, 21);
INSERT INTO kierowcy_pojazdy VALUES (15, 22);
INSERT INTO kierowcy_pojazdy VALUES (15, 23);
INSERT INTO kierowcy_pojazdy VALUES (16, 24);
INSERT INTO kierowcy_pojazdy VALUES (17, 25);
INSERT INTO kierowcy_pojazdy VALUES (18, 26);
INSERT INTO kierowcy_pojazdy VALUES (19, 27);
INSERT INTO kierowcy_pojazdy VALUES (20, 28);
INSERT INTO kierowcy_pojazdy VALUES (21, 29);
INSERT INTO kierowcy_pojazdy VALUES (21, 30);
INSERT INTO kierowcy_pojazdy VALUES (22, 31);
INSERT INTO kierowcy_pojazdy VALUES (22, 32);
INSERT INTO kierowcy_pojazdy VALUES (23, 33);
INSERT INTO kierowcy_pojazdy VALUES (24, 34);
INSERT INTO kierowcy_pojazdy VALUES (24, 35);
INSERT INTO kierowcy_pojazdy VALUES (25, 36);
INSERT INTO kierowcy_pojazdy VALUES (25, 37);
INSERT INTO kierowcy_pojazdy VALUES (26, 38);
INSERT INTO kierowcy_pojazdy VALUES (27, 39);
INSERT INTO kierowcy_pojazdy VALUES (27, 40);
INSERT INTO kierowcy_pojazdy VALUES (28, 41);
INSERT INTO kierowcy_pojazdy VALUES (28, 42);
INSERT INTO kierowcy_pojazdy VALUES (29, 43);
INSERT INTO kierowcy_pojazdy VALUES (30, 44);
INSERT INTO kierowcy_pojazdy VALUES (31, 45);
INSERT INTO kierowcy_pojazdy VALUES (31, 46);
INSERT INTO kierowcy_pojazdy VALUES (32, 47);
INSERT INTO kierowcy_pojazdy VALUES (32, 48);
INSERT INTO kierowcy_pojazdy VALUES (33, 49);
INSERT INTO kierowcy_pojazdy VALUES (33, 50);
INSERT INTO kierowcy_pojazdy VALUES (34, 51);
INSERT INTO kierowcy_pojazdy VALUES (34, 52);
INSERT INTO kierowcy_pojazdy VALUES (35, 53);
INSERT INTO kierowcy_pojazdy VALUES (36, 54);
INSERT INTO kierowcy_pojazdy VALUES (36, 55);
INSERT INTO kierowcy_pojazdy VALUES (37, 56);
INSERT INTO kierowcy_pojazdy VALUES (37, 57);
INSERT INTO kierowcy_pojazdy VALUES (38, 58);
INSERT INTO kierowcy_pojazdy VALUES (39, 59);
INSERT INTO kierowcy_pojazdy VALUES (40, 60);
INSERT INTO kierowcy_pojazdy VALUES (41, 61);
INSERT INTO kierowcy_pojazdy VALUES (42, 62);
INSERT INTO kierowcy_pojazdy VALUES (43, 63);
INSERT INTO kierowcy_pojazdy VALUES (44, 64);
INSERT INTO kierowcy_pojazdy VALUES (45, 65);
INSERT INTO kierowcy_pojazdy VALUES (46, 66);
INSERT INTO kierowcy_pojazdy VALUES (47, 67);
INSERT INTO kierowcy_pojazdy VALUES (48, 68);
INSERT INTO kierowcy_pojazdy VALUES (48, 69);
INSERT INTO kierowcy_pojazdy VALUES (49, 70);
INSERT INTO kierowcy_pojazdy VALUES (50, 71);
INSERT INTO kierowcy_pojazdy VALUES (51, 72);
INSERT INTO kierowcy_pojazdy VALUES (52, 73);
INSERT INTO kierowcy_pojazdy VALUES (52, 74);
INSERT INTO kierowcy_pojazdy VALUES (53, 75);
INSERT INTO kierowcy_pojazdy VALUES (53, 76);
INSERT INTO kierowcy_pojazdy VALUES (54, 77);
INSERT INTO kierowcy_pojazdy VALUES (55, 78);
INSERT INTO kierowcy_pojazdy VALUES (56, 79);
INSERT INTO kierowcy_pojazdy VALUES (57, 80);
INSERT INTO kierowcy_pojazdy VALUES (57, 81);
INSERT INTO kierowcy_pojazdy VALUES (58, 82);
INSERT INTO kierowcy_pojazdy VALUES (58, 83);
INSERT INTO kierowcy_pojazdy VALUES (59, 84);
INSERT INTO kierowcy_pojazdy VALUES (59, 85);
INSERT INTO kierowcy_pojazdy VALUES (60, 86);
INSERT INTO kierowcy_pojazdy VALUES (60, 87);
INSERT INTO kierowcy_pojazdy VALUES (61, 88);
INSERT INTO kierowcy_pojazdy VALUES (61, 89);
INSERT INTO kierowcy_pojazdy VALUES (62, 90);
INSERT INTO kierowcy_pojazdy VALUES (62, 91);
INSERT INTO kierowcy_pojazdy VALUES (63, 92);
INSERT INTO kierowcy_pojazdy VALUES (64, 93);
INSERT INTO kierowcy_pojazdy VALUES (64, 94);
INSERT INTO kierowcy_pojazdy VALUES (65, 95);
INSERT INTO kierowcy_pojazdy VALUES (65, 96);
INSERT INTO kierowcy_pojazdy VALUES (66, 97);
INSERT INTO kierowcy_pojazdy VALUES (67, 98);
INSERT INTO kierowcy_pojazdy VALUES (67, 99);
INSERT INTO kierowcy_pojazdy VALUES (68, 100);
INSERT INTO kierowcy_pojazdy VALUES (68, 101);
INSERT INTO kierowcy_pojazdy VALUES (69, 102);
INSERT INTO kierowcy_pojazdy VALUES (70, 103);
INSERT INTO kierowcy_pojazdy VALUES (70, 104);
INSERT INTO kierowcy_pojazdy VALUES (71, 105);
INSERT INTO kierowcy_pojazdy VALUES (72, 106);
INSERT INTO kierowcy_pojazdy VALUES (72, 107);
INSERT INTO kierowcy_pojazdy VALUES (73, 108);
INSERT INTO kierowcy_pojazdy VALUES (73, 109);
INSERT INTO kierowcy_pojazdy VALUES (74, 110);
INSERT INTO kierowcy_pojazdy VALUES (74, 111);
INSERT INTO kierowcy_pojazdy VALUES (75, 112);
INSERT INTO kierowcy_pojazdy VALUES (76, 113);
INSERT INTO kierowcy_pojazdy VALUES (76, 114);
INSERT INTO kierowcy_pojazdy VALUES (77, 115);
INSERT INTO kierowcy_pojazdy VALUES (78, 116);
INSERT INTO kierowcy_pojazdy VALUES (79, 117);
INSERT INTO kierowcy_pojazdy VALUES (79, 118);
INSERT INTO kierowcy_pojazdy VALUES (80, 119);
INSERT INTO kierowcy_pojazdy VALUES (80, 120);
INSERT INTO kierowcy_pojazdy VALUES (81, 121);
INSERT INTO kierowcy_pojazdy VALUES (81, 122);
INSERT INTO kierowcy_pojazdy VALUES (82, 123);
INSERT INTO kierowcy_pojazdy VALUES (83, 124);
INSERT INTO kierowcy_pojazdy VALUES (83, 125);
INSERT INTO kierowcy_pojazdy VALUES (84, 126);
INSERT INTO kierowcy_pojazdy VALUES (84, 127);
INSERT INTO kierowcy_pojazdy VALUES (85, 128);
INSERT INTO kierowcy_pojazdy VALUES (86, 129);
INSERT INTO kierowcy_pojazdy VALUES (87, 130);
INSERT INTO kierowcy_pojazdy VALUES (88, 131);
INSERT INTO kierowcy_pojazdy VALUES (89, 132);
INSERT INTO kierowcy_pojazdy VALUES (90, 133);
INSERT INTO kierowcy_pojazdy VALUES (90, 134);
INSERT INTO kierowcy_pojazdy VALUES (91, 135);
INSERT INTO kierowcy_pojazdy VALUES (91, 136);
INSERT INTO kierowcy_pojazdy VALUES (92, 137);
INSERT INTO kierowcy_pojazdy VALUES (93, 138);
INSERT INTO kierowcy_pojazdy VALUES (93, 139);
INSERT INTO kierowcy_pojazdy VALUES (94, 140);
INSERT INTO kierowcy_pojazdy VALUES (94, 141);
INSERT INTO kierowcy_pojazdy VALUES (95, 142);
INSERT INTO kierowcy_pojazdy VALUES (96, 143);
INSERT INTO kierowcy_pojazdy VALUES (96, 144);
INSERT INTO kierowcy_pojazdy VALUES (97, 145);
INSERT INTO kierowcy_pojazdy VALUES (98, 146);
INSERT INTO kierowcy_pojazdy VALUES (98, 147);
INSERT INTO kierowcy_pojazdy VALUES (99, 148);
INSERT INTO kierowcy_pojazdy VALUES (100, 149);
COMMIT;