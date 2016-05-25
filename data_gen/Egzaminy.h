//
// Created by Dom on 2016-05-24.
//

#ifndef ID_GENERATORKA_EGZAMINY_H
#define ID_GENERATORKA_EGZAMINY_H


class Egzaminy
{
private:

    static int objects;
    int id_egzaminu;
    string data_przeprowadzenia;
    string typ; // teoria/praktyka
    int id_egzaminatora;
    int id_osrodka;

public:

    Egzaminy(int, string*);
    void wypisz();
    int getId() const {return id_egzaminu;}

};

int Egzaminy::objects = 0;

Egzaminy::Egzaminy(int cdata = 0, string* data = nullptr)
{
    id_egzaminu = ++objects;

    if(!cdata) generuj_date(data_przeprowadzenia);
    else data_przeprowadzenia = *data;

    if(rand()%2) typ = "teoria";
    else typ = "praktyka";

    id_egzaminatora = egzaminatorzy[rand()%egzaminatorzy.size()].getId();
    id_osrodka = osrodki[rand()%osrodki.size()].getId();

}



void Egzaminy::wypisz()
{
    cout << "(";
    cout << id_egzaminu << ", ";
    cout << "'" << data_przeprowadzenia << "', ";
    cout << "'" << typ << "', ";
    cout << id_egzaminatora << ", ";
    cout << id_osrodka;
    cout << ")";
    //cout << endl;
}

vector<Egzaminy> egzaminy;



#endif //ID_GENERATORKA_EGZAMINY_H
