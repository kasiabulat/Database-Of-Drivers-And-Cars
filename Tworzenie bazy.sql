DROP TABLE IF EXISTS pojazdy CASCADE ;
DROP TABLE IF EXISTS kierowcy CASCADE;
DROP TABLE IF EXISTS kierowcy_pojazdy CASCADE;
DROP TABLE IF EXISTS prawa_jazdy CASCADE;
DROP TABLE IF EXISTS prawa_jazdy_kategorie CASCADE;
DROP TYPE IF EXISTS typ_egzaminu CASCADE;
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
	wysokość_grzywny NUMERIC(5,2),
	punkty_karne NUMERIC(2) NOT NULL
);

CREATE TABLE mandaty(
	id_mandatu SERIAL PRIMARY KEY,
	id_kierowcy INT REFERENCES kierowcy NOT NULL ,
	id_wystawiającego INT REFERENCES mandaty_wystawiający(id_wstawiającego) NOT NULL ,
	id_wykroczenia INT REFERENCES wykroczenia NOT NULL
);


