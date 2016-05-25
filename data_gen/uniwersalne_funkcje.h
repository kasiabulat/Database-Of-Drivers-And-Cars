//
// Created by Dom on 2016-05-23.
//

#ifndef ID_GENERATORKA_UNIWERSALNE_FUNKCJE_H
#define ID_GENERATORKA_UNIWERSALNE_FUNKCJE_H

#include <string>

void wczytaj_dane(vector<string>& V, const int& n)
{
    cin.ignore();
    for (int i = 0; i < n; ++i) {
        string S;
        getline(cin, S);
        V.push_back(S);
    }
}

void wczytaj_samochody(vector< pair< string, string > >& V, const int& n)
{
    cin.ignore();
    for (int i = 0; i < n; ++i) {
        string S, marka, model;
        getline(cin, S);
        marka = model = "";
        for (int j = 0; j < S.size(); ++j) {
            if(S[j] == ',')
            {
                marka = S.substr(0, j);
                model = S.substr(j+1);
                break;
            }
        }
        V.push_back(make_pair(marka, model));
    }
}

void generuj_imie_nazwisko(int plec, string& imie, string& nazwisko)
{
    // Generuj imie i nazwisko
    if(plec == 0)
    {
        imie = losowe_imiona_damskie[rand()%losowe_imiona_damskie.size()];
        nazwisko = losowe_nazwiska_damskie[rand()%losowe_nazwiska_damskie.size()];
    }
    else
    {
        imie = losowe_imiona_meskie[rand()%losowe_imiona_meskie.size()];
        nazwisko = losowe_nazwiska_meskie[rand()%losowe_nazwiska_meskie.size()];
    }
}


void generuj_date(string& data)
{
    int rok = rand()%40 + 1975;
    int miesiac = rand()%12 + 1;
    int dzien = rand()%30 + 1;

    string rozdziel1 = "-", rozdziel2 = "-";
    if(miesiac<10) rozdziel1 += "0";
    if(miesiac == 2 && dzien>28) dzien = rand()%28 + 1;
    if(dzien<10) rozdziel2 += "0";



    ostringstream ss, ss2, ss3;
    ss << rok;
    ss2 << miesiac;
    ss3 << dzien;
    data = ss.str() + rozdziel1 + ss2.str() + rozdziel2 + ss3.str(); // to_string() z c++11 nie kompiluje sie u mnie???
}

int ascii_cyfra(int a, int b)  // generuje kod ascii liczby z przedzialu [a;b]
{
    return rand()%(b-a+1) + 48 + a;
}

int ascii_mala_litera()
{
    return rand()%26 + 97;
}

int ascii_duza_litera()
{
    return rand()%26 + 65;
}

void generuj_adres(string& adres)
{
    // Generuj adres
    adres = losowe_ulice[rand()%losowe_ulice.size()];
    adres += " ";
    adres += ascii_cyfra(0, 9);  // dowolna cyfra
    adres += ascii_cyfra(0, 9); // dowolna cyfra
    adres += "/";
    adres += ascii_cyfra(0, 9);  // dowolna cyfra
    adres += ascii_cyfra(0, 9);  // dowolna cyfra

}

#endif //ID_GENERATORKA_UNIWERSALNE_FUNKCJE_H
