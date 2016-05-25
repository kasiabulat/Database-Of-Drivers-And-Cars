//
// Created by Dom on 2016-05-25.
//

#ifndef ID_GENERATORKA_KIEROWCY_POJAZDY_H
#define ID_GENERATORKA_KIEROWCY_POJAZDY_H


class Kierowcy_pojazdy
{
private:

    static int objects;
    int id_kierowcy;
    int id_pojazdu;

public:

    Kierowcy_pojazdy();
    void wypisz();

};

int Kierowcy_pojazdy::objects = 0;

Kierowcy_pojazdy::Kierowcy_pojazdy()
{
    ++objects;
    id_pojazdu = pojazdy[rand()%pojazdy.size()].getId();
    id_kierowcy = kierowcy[rand()%kierowcy.size()].getId();

}

void Kierowcy_pojazdy::wypisz()
{
    cout << "(";
    cout << id_kierowcy << ", ";
    cout << id_pojazdu;
    cout << ")";
    //cout << endl;
}

vector<Kierowcy_pojazdy> kierowcy_pojazdy;



#endif //ID_GENERATORKA_KIEROWCY_POJAZDY_H
