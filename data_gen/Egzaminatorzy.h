//
// Created by Dom on 2016-05-23.
//

#ifndef ID_GENERATORKA_EGZAMINATORZY_H
#define ID_GENERATORKA_EGZAMINATORZY_H

class Egzaminatorzy
{
private:

    static int objects;
    int id_egzaminatora;
    string imie;
    string nazwisko;

public:

    Egzaminatorzy();
    void wypisz();
    int getId() const {return id_egzaminatora;}

};

int Egzaminatorzy::objects = 0;

Egzaminatorzy::Egzaminatorzy()
{
    id_egzaminatora = ++objects;

    int plec = rand()%2;
    generuj_imie_nazwisko(plec, imie, nazwisko);

}

void Egzaminatorzy::wypisz()
{
    cout << "(";
    cout << id_egzaminatora << ", ";
    cout << "'" << imie << "', ";
    cout << "'" << nazwisko << "'";
    cout << ")";
    //cout << endl;
}

vector<Egzaminatorzy> egzaminatorzy;

#endif //ID_GENERATORKA_EGZAMINATORZY_H
