//
// Created by Dom on 2016-05-23.
//

#ifndef ID_GENERATORKA_OSRODKI_H
#define ID_GENERATORKA_OSRODKI_H

class Osrodki
{
private:

    static int objects;
    int id_osrodka;
    string nazwa;
    string adres;

public:

    Osrodki();
    void wypisz();
    int getId() const {return id_osrodka;}

};

int Osrodki::objects = 0;

Osrodki::Osrodki()
{
    id_osrodka = ++objects;

    generuj_adres(adres);

    ostringstream ss;
    ss << id_osrodka;
    nazwa = "tymczasowy osrodek" + ss.str();
}

void Osrodki::wypisz()
{
    cout << "(";
    cout << id_osrodka << ", ";
    cout << "'" << nazwa << "', ";
    cout << "'" << adres << "'";
    cout << ")";
    //cout << endl;
}


vector<Osrodki> osrodki;


#endif //ID_GENERATORKA_OSRODKI_H
