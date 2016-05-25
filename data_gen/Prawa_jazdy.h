//
// Created by Dom on 2016-05-25.
//

#ifndef ID_GENERATORKA_PRAWA_JAZDY_H
#define ID_GENERATORKA_PRAWA_JAZDY_H


class Prawa_jazdy
{
private:

    static int objects;
    string numer_prawa_jazdy;
    int id_wlasciciela;
    string data_wydania;
    bool miedzynarodowe;

public:

    Prawa_jazdy();
    void wypisz();
    string getId() const {return numer_prawa_jazdy;}

};

int Prawa_jazdy::objects = 0;

Prawa_jazdy::Prawa_jazdy()
{
    ++objects;

    id_wlasciciela = kierowcy[rand()%kierowcy.size()].getId();

    generuj_date(data_wydania);
    numer_prawa_jazdy = "";

    for (int i = 0; i < 5; ++i) {
        numer_prawa_jazdy += ascii_cyfra(0, 9);
    }
    numer_prawa_jazdy += "/";
    numer_prawa_jazdy += data_wydania.substr(5, 2);
    numer_prawa_jazdy += "/";
    for (int i = 0; i < 4; ++i) {
        numer_prawa_jazdy += ascii_cyfra(0, 9);
    }

    if(rand()%64 == 0) miedzynarodowe = true;
    else miedzynarodowe = false;

}

void Prawa_jazdy::wypisz()
{
    cout << "(";
    cout << "'" << numer_prawa_jazdy << "', ";
    cout << id_wlasciciela << ", ";
    cout << "'" << data_wydania << "', ";
    if(miedzynarodowe) cout << "true";
    else cout << "false";
    cout << ")";
    //cout << endl;
}

vector<Prawa_jazdy> prawa_jazdy;


#endif //ID_GENERATORKA_PRAWA_JAZDY_H
