//
// Created by Dom on 2016-05-24.
//

#ifndef ID_GENERATORKA_POJAZDY_H
#define ID_GENERATORKA_POJAZDY_H

class Pojazdy
{
private:

    static int objects;
    int id_pojazdu;
    string nr_rejestracyjny;
    string data_rejestracji;
    string marka;
    string model;
    string typ;

public:

    Pojazdy();
    void wypisz();
    int getId() const {return id_pojazdu;}

};

int Pojazdy::objects = 0;

Pojazdy::Pojazdy()
{
    id_pojazdu = ++objects;

    generuj_date(data_rejestracji);

    int samochod = rand()%losowe_samochody.size();
    marka = losowe_samochody[samochod].first;    // wylosuj samochod
    model = losowe_samochody[samochod].second;
    if(rand()%32 == 0) typ = "ciężarowy";
    else typ = "osobowy";

    nr_rejestracyjny += losowe_kody_tablic[rand()%losowe_kody_tablic.size()];
    int dolosuj = 7 - nr_rejestracyjny.size();

    nr_rejestracyjny += ascii_cyfra(0, 9);  // pierwsza cyfra po kodzie powiatu to cyfra
    for (int i = 1; i < dolosuj; ++i) {

        if(rand()%2 && (i == 1 || i == dolosuj-1 || i == dolosuj-2)) // zeby wygladaly ladniej ;p
        {
            nr_rejestracyjny += ascii_duza_litera();   // losuje litere
        }
        else
        {
            nr_rejestracyjny += ascii_cyfra(0, 9);   //losowa cyfre
        }
    }
}

void Pojazdy::wypisz()
{
    cout << "(";
    cout << id_pojazdu << ", ";
    cout << "'" << nr_rejestracyjny << "', ";
    cout << "'" << data_rejestracji << "', ";
    cout << "'" << marka << "', ";
    cout << "'" << model << "', ";
    cout << "'" << typ << "'";
    cout << ")";
    //cout << endl;
}


vector<Pojazdy> pojazdy;


#endif //ID_GENERATORKA_POJAZDY_H
