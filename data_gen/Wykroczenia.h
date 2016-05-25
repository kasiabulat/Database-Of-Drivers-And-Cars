//
// Created by Dom on 2016-05-24.
//

#ifndef ID_GENERATORKA_WYKROCZENIA_H
#define ID_GENERATORKA_WYKROCZENIA_H

class Wykroczenia
{
private:

    static int objects;
    int id_wykroczenia;
    string opis;
    double wysokosc_grzywny;
    int punkty_karne;

public:

    Wykroczenia();
    void wypisz();
    int getId() const {return id_wykroczenia;}

};

int Wykroczenia::objects = 0;

Wykroczenia::Wykroczenia()
{
    id_wykroczenia = ++objects;

    punkty_karne = rand()%10 + 1;   // zeby mialo to sens, gorzej bywa baardzo rzadko

    wysokosc_grzywny = rand()%900 + 50;    //
    wysokosc_grzywny -= (static_cast<int>(wysokosc_grzywny)%10);  // zeby byla okragla co do dziesiatek
    wysokosc_grzywny += (static_cast<double>(rand()%100));  // aczkolwiek nie wiem po co, taryfikator ma przeciez kwoty postaci 10*x

    if(rand()%2) opis = "wykroczenie bylo bylo";
    else opis = "a to juz wgl niedopuszczalne!";
}


void Wykroczenia::wypisz()
{
    cout << "(";
    cout << id_wykroczenia << ", ";
    cout << "'" << opis << "', ";
    cout << wysokosc_grzywny << ", ";
    cout << punkty_karne;
    cout << ")";
    //cout << endl;
}

vector<Wykroczenia> wykroczenia;

#endif //ID_GENERATORKA_WYKROCZENIA_H
