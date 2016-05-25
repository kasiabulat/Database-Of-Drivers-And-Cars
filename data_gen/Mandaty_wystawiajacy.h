//
// Created by Dom on 2016-05-23.
//

#ifndef ID_GENERATORKA_MANDATY_WYSTAWIAJACY_H
#define ID_GENERATORKA_MANDATY_WYSTAWIAJACY_H

class Mandaty_wystawiajacy
{
private:

    static int objects;
    int id_wystawiajacego;
    string imie;
    string nazwisko;

public:

    Mandaty_wystawiajacy();
    void wypisz();
    int getId() const {return id_wystawiajacego;}

};

int Mandaty_wystawiajacy::objects = 0;

Mandaty_wystawiajacy::Mandaty_wystawiajacy()
{
    id_wystawiajacego = ++objects;

    int plec = rand()%2;
    generuj_imie_nazwisko(plec, imie, nazwisko);

}

void Mandaty_wystawiajacy::wypisz()
{
    cout << "(";
    cout << id_wystawiajacego << ", ";
    cout << "'" << imie << "', ";
    cout << "'" << nazwisko << "'";
    cout << ")";
    //cout << endl;
}

vector<Mandaty_wystawiajacy> mandaty_wystawiajacy;



#endif //ID_GENERATORKA_MANDATY_WYSTAWIAJACY_H
