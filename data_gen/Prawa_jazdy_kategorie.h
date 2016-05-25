//
// Created by Dom on 2016-05-25.
//

#ifndef ID_GENERATORKA_PRAWA_JAZDY_KATEGORIE_H
#define ID_GENERATORKA_PRAWA_JAZDY_KATEGORIE_H

class Prawa_jazdy_kategorie
{
private:

    static int objects;
    string numer_prawa_jazdy;
    string kategoria;

public:

    Prawa_jazdy_kategorie();
    void wypisz();

};

int Prawa_jazdy_kategorie::objects = 0;

Prawa_jazdy_kategorie::Prawa_jazdy_kategorie()
{
    ++objects;
    numer_prawa_jazdy = prawa_jazdy[rand()%prawa_jazdy.size()].getId();
    kategoria = ascii_duza_litera();
}

void Prawa_jazdy_kategorie::wypisz()
{
    cout << "(";
    cout << "'" << numer_prawa_jazdy << "', ";
    cout << "'" << kategoria << "'";
    cout << ")";
    //cout << endl;
}

vector<Prawa_jazdy_kategorie> prawa_jazdy_kategorie;


#endif //ID_GENERATORKA_PRAWA_JAZDY_KATEGORIE_H
