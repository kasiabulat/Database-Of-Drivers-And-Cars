//
// Created by Michal Stobierski on 2016-05-23.
//

#ifndef KIEROWCA_H
#define KIEROWCA_H

#include <iostream>
#include <bits/stdc++.h>
using namespace std;

class Kierowca
{
private:
    static int objects;

    int id_kierowcy;
    long long pesel;
    string imie;
    string nazwisko;
    string email;
    string nr_telefonu;
    string adres;

public:

    Kierowca();

    void wypisz();
    int getId() const {return id_kierowcy;}

};



int Kierowca::objects = 0;

Kierowca::Kierowca()
{
    id_kierowcy = ++objects; // przypisz id

    int plec = rand()%2;    // 0 - K, 1 - M

    // Generowanie prawdziwego PESELu
    int suma_kontrolna = 0;
    pesel = 0LL;

    int temp = rand()%90 + 10;  // rok urodzenia
    pesel += temp;
    suma_kontrolna += ((temp/10) + (temp%10)*3);

    temp = rand()%12 + 1;   // miesiac urodzenia
    pesel *= 100; pesel += temp;
    suma_kontrolna += ((temp/10)*7 + (temp%10)*9);

    temp = rand()%31 + 1;   // dzien urodzenia
    pesel *= 100; pesel += temp;
    suma_kontrolna += ((temp/10) + (temp%10)*3);

    temp = rand()%100;  // byle co
    pesel *= 100; pesel += temp;
    suma_kontrolna += ((temp/10)*7 + (temp%10)*9);

    temp = rand()%99 + 1;  // znowu
    if(plec == 0 && temp%2 == 1) temp--;    // plec jest 10 cyfra peselu, zalezy od parzystosci
    else if(plec == 1 && temp%2 == 0) temp--;
    pesel *= 100; pesel += temp;
    suma_kontrolna += ((temp/10)*1 + (temp%10)*3);

    pesel *= 10; pesel += ((10 - (suma_kontrolna%10))%10);

    // uff, koniec PESELU

    // Generuj imie i nazwisko
    generuj_imie_nazwisko(plec, imie, nazwisko);

    // Generuj mail
    email = "";
    for (int i = 0, fin = rand()%9+3; i < fin; ++i) {
        email += ascii_mala_litera();
    }
    email += losowe_maile[rand()%losowe_maile.size()];

    // Generuj nr telefonu
    nr_telefonu = ascii_cyfra(5, 8);    // cyfra od 5-8
    for (int i = 1; i < 9; ++i) {
        nr_telefonu += ascii_cyfra(0, 9);    // dowolna cyfra
    }

    // Generuj adres
    generuj_adres(adres);

}



void Kierowca::wypisz()
{
    cout << "(";
    cout << id_kierowcy << ", ";
    cout << "'" << pesel << "', ";
    cout << "'" << imie << "', ";
    cout << "'" << nazwisko << "', ";
    cout << "'" << email << "', ";
    cout << "'" << nr_telefonu << "', ";
    cout << "'" << adres << "'";
    cout << ")";
    //cout << endl;
}

vector<Kierowca> kierowcy;

#endif //KIEROWCA_H
