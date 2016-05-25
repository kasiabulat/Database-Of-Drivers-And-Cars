//
// Created by Michal Stobierski on 2016-05-22.
//

#include <iostream>
#include <bits/stdc++.h>
using namespace std;

#include "struktury_danych.h"
#include "uniwersalne_funkcje.h"
#include "Egzaminatorzy.h"
#include "Osrodki.h"
#include "Mandaty_wystawiajacy.h"
#include "Wykroczenia.h"
#include "Pojazdy.h"
#include "Kierowca.h"
#include "Mandaty.h"
#include "Egzaminy.h"
#include "Wyniki_egzaminow.h"
#include "Kierowcy_pojazdy.h"
#include "Prawa_jazdy.h"
#include "Prawa_jazdy_kategorie.h"


int main()
{
    ios_base::sync_with_stdio(0);
    srand(time(0));

    int n;
    // Wczytuje imiona damskie
    cin >> n;
    wczytaj_dane(losowe_imiona_damskie, n);

    // Wczytuje imiona meskie
    cin >> n;
    wczytaj_dane(losowe_imiona_meskie, n);

    // Wczytuje nazwiska damskie
    cin >> n;
    wczytaj_dane(losowe_nazwiska_damskie, n);

    // Wczytuje nazwiska meskie
    cin >> n;
    wczytaj_dane(losowe_nazwiska_meskie, n);

    // Wczytuje adresy
    cin >> n;
    wczytaj_dane(losowe_ulice, n);

    // Wczytuje sufiksy maili @nazwa.pl
    cin >> n;
    wczytaj_dane(losowe_maile, n);

    // Wczytuje marki i modele samochodow
    cin >> n;
    wczytaj_samochody(losowe_samochody, n);

    // Wczytuje polskie kody tablic samochodowych
    cin >> n;
    wczytaj_dane(losowe_kody_tablic, n);

    //cout << "WCZYTALEM DANE" << endl;


    //--------------------------------------------------------- GENERUJE KROTKI (kolejnosc ma znaczenie!)

    // Generuj egzaminatorow
    const int ilu_egzaminatorow = 64;
    for (int i = 0; i < ilu_egzaminatorow; ++i) {
        Egzaminatorzy nowy;
        egzaminatorzy.push_back(nowy);
    }

    // Generuj osrodki
    const int ile_osrodkow = 16;
    for (int i = 0; i < ile_osrodkow; ++i) {
        Osrodki nowy;
        osrodki.push_back(nowy);
    }
    
    // Generuj wystawiajacych mandaty
    const int ilu_wystawiajacych = 16;
    for (int i = 0; i < ilu_wystawiajacych; ++i) {
        Mandaty_wystawiajacy nowy;
        mandaty_wystawiajacy.push_back(nowy);
    }

    // Generuj wykroczenia
    const int ile_wykroczen = 128;
    for (int i = 0; i < ile_wykroczen; ++i) {
        Wykroczenia nowy;
        wykroczenia.push_back(nowy);
    }

    // Generuj pojazdy
    const int ile_pojazdow = 1000;
    for (int i = 0; i < ile_pojazdow; ++i) {
        Pojazdy nowy;
        pojazdy.push_back(nowy);
    }

    // Generuj kierowcow
    const int ilu_kierowcow = 1024;
    for (int i = 0; i < ilu_kierowcow; ++i) {
        Kierowca nowy;
        kierowcy.push_back(nowy);
    }

    // Generuj tabele mandaty
    const int ile_mandatow = 128;
    for (int i = 0; i < ile_mandatow; ++i) {
        Mandaty nowy;
        mandaty.push_back(nowy);
    }

    // Generuj tabele egzaminy
    const int ile_egzaminow = 3*ilu_kierowcow;
    for (int i = 0; i < ile_egzaminow; ++i) {
        Egzaminy nowy;
        egzaminy.push_back(nowy);
    }

    // Generuj tabele wyniki_egzaminow
    const int ile_wynikow_egzaminow = ile_egzaminow;
    for (int i = 0; i < ile_wynikow_egzaminow; ++i) {
        Wyniki_egzaminow nowy;
        wyniki_egzaminow.push_back(nowy);
    }

    // Generuj tabele kierowcy_pojazdy
    const int ile_kierowcow_pojazdow = ile_pojazdow;
    for (int i = 0; i < ile_kierowcow_pojazdow; ++i) {
        Kierowcy_pojazdy nowy;
        kierowcy_pojazdy.push_back(nowy);
    }

    // Generuj tabele prawa_jazdy
    const int ile_praw_jazdy = 2*ilu_kierowcow;
    for (int i = 0; i < ile_praw_jazdy; ++i) {
        Prawa_jazdy nowy;
        prawa_jazdy.push_back(nowy);
    }

    // Generuj tabele prawa_jazdy_kategorie
    const int ile_praw_jazdy_kategorii = 2*ile_praw_jazdy;
    for (int i = 0; i < ile_praw_jazdy_kategorii; ++i) {
        Prawa_jazdy_kategorie nowy;
        prawa_jazdy_kategorie.push_back(nowy);
    }

    //--------------------------------------------------------- GENERUJE TRESC ZAPYTANIA (kolejnosc ma znaczenie!)

    for (int i = 0; i < ilu_kierowcow; ++i) {
        cout << "INSERT INTO kierowcy VALUES ";
        kierowcy[i].wypisz();
        cout << ";" << endl;
    }

    for (int i = 0; i < ilu_egzaminatorow; ++i) {
        cout << "INSERT INTO egzaminatorzy VALUES ";
        egzaminatorzy[i].wypisz();
        cout << ";" << endl;
    }

    for (int i = 0; i < ile_osrodkow; ++i) {
        cout << "INSERT INTO ośrodki VALUES ";
        osrodki[i].wypisz();
        cout << ";" << endl;
    }


    for (int i = 0; i < ilu_wystawiajacych; ++i) {
        cout << "INSERT INTO mandaty_wystawiający VALUES ";
        mandaty_wystawiajacy[i].wypisz();
        cout << ";" << endl;
    }

    for (int i = 0; i < ile_wykroczen; ++i) {
        cout << "INSERT INTO wykroczenia VALUES ";
        wykroczenia[i].wypisz();
        cout << ";" << endl;
    }

    for (int i = 0; i < ile_mandatow; ++i) {
        cout << "INSERT INTO mandaty VALUES ";
        mandaty[i].wypisz();
        cout << ";" << endl;
    }

    for (int i = 0; i < ile_egzaminow; ++i) {
        cout << "INSERT INTO egzaminy VALUES ";
        egzaminy[i].wypisz();
        cout << ";" << endl;
    }

    for (int i = 0; i < ile_wynikow_egzaminow; ++i) {
        cout << "INSERT INTO wyniki_egzaminów VALUES ";
        wyniki_egzaminow[i].wypisz();
        cout << ";" << endl;
    }

    for (int i = 0; i < ile_praw_jazdy; ++i) {
        cout << "INSERT INTO prawa_jazdy VALUES ";
        prawa_jazdy[i].wypisz();
        cout << ";" << endl;
    }

    for (int i = 0; i < ile_praw_jazdy_kategorii; ++i) {
        cout << "INSERT INTO prawa_jazdy_kategorie VALUES ";
        prawa_jazdy_kategorie[i].wypisz();
        cout << ";" << endl;
    }

    for (int i = 0; i < ile_pojazdow; ++i) {
        cout << "INSERT INTO pojazdy VALUES ";
        pojazdy[i].wypisz();
        cout << ";" << endl;
    }

    for (int i = 0; i < ile_kierowcow_pojazdow; ++i) {
        cout << "INSERT INTO kierowcy_pojazdy VALUES ";
        kierowcy_pojazdy[i].wypisz();
        cout << ";" << endl;
    }







    return 0;
}