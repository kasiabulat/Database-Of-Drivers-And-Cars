//
// Created by Dom on 2016-05-24.
//

#ifndef ID_GENERATORKA_MANDATY_H
#define ID_GENERATORKA_MANDATY_H

class Mandaty
{
private:

    static int objects;
    int id_mandatu;
    int id_kierowcy;
    int id_wystawiajacego;
    int id_wykroczenia;

public:

    Mandaty();
    void wypisz();

};

int Mandaty::objects = 0;

Mandaty::Mandaty()
{
    id_mandatu = ++objects;

    id_kierowcy = kierowcy[rand()%kierowcy.size()].getId();
    id_wystawiajacego = mandaty_wystawiajacy[rand()%mandaty_wystawiajacy.size()].getId();
    id_wykroczenia = wykroczenia[rand()%wykroczenia.size()].getId();
}

void Mandaty::wypisz()
{
    cout << "(";
    cout << id_mandatu << ", ";
    cout << id_kierowcy << ", ";
    cout << id_wystawiajacego << ", ";
    cout << id_wykroczenia;
    cout << ")";
    //cout << endl;
}

vector<Mandaty> mandaty;



#endif //ID_GENERATORKA_MANDATY_H
