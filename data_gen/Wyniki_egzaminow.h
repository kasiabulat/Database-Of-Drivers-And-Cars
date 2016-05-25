//
// Created by Dom on 2016-05-24.
//

#ifndef ID_GENERATORKA_WYNIKI_EGZAMINOW_H
#define ID_GENERATORKA_WYNIKI_EGZAMINOW_H


class Wyniki_egzaminow
{
private:

    static int objects;
    int id_egzaminu;
    int id_kierowcy;
    string wynik;

public:

    Wyniki_egzaminow();
    void wypisz();

};

int Wyniki_egzaminow::objects = 0;

Wyniki_egzaminow::Wyniki_egzaminow()
{
    id_egzaminu = egzaminy[rand()%egzaminy.size()].getId();
    id_kierowcy = kierowcy[rand()%kierowcy.size()].getId();

    if(rand()%16 == 0)
    {
        wynik = "nie stawił się";
        return;
    }
    if(rand()%2) wynik = "zdał";
    else wynik = "nie zdał";
}

void Wyniki_egzaminow::wypisz()
{
    cout << "(";
    cout << id_egzaminu << ", ";
    cout << id_kierowcy << ", ";
    cout << "'" << wynik << "'";
    cout << ")";
    //cout << endl;
}

vector<Wyniki_egzaminow> wyniki_egzaminow;




#endif //ID_GENERATORKA_WYNIKI_EGZAMINOW_H
