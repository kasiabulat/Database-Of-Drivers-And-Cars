import java.io.FileNotFoundException;
import java.io.PrintWriter;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

class Main {

    private static final int MODELI = 512;
    private static final int EGZAMINATOROW = 32;
    private static final int OSRODKOW = 16;
    private static final int WYST_WYKROCZENIA = 16;
    private static final int WYKROCZEN = 32;
    private static final int KIEROWCOW = 100;

    private static void wczytaj_dane() {

        // Wczytaj imiona damskie
        Dane.wczytaj_z_pliku("imiona_damskie.txt", Dane.imionaDamskie);

        // Wczytaj imiona meskie
        Dane.wczytaj_z_pliku("imiona_meskie.txt", Dane.imionaMeskie);

        // Wczytaj nazwiska damskie
        Dane.wczytaj_z_pliku("nazwiska_damskie.txt", Dane.nazwiskaDamskie);

        // Wczytaj nazwiska meskie
        Dane.wczytaj_z_pliku("nazwiska_meskie.txt", Dane.nazwiskaMeskie);

        // Wczytaj adresy
        Dane.wczytaj_z_pliku("ulice.txt", Dane.adresy);

        // Wczytaj domeny mailowe
        Dane.wczytaj_z_pliku("domeny_mailowe.txt", Dane.domenyMailowe);

        // Wczytaj marki i modele samochodow
        Dane.wczytaj_z_pliku("pojazdyv2.txt", Dane.samochody);

        // Wczytaj polskie tablice samochodowe
        Dane.wczytaj_z_pliku("kody_tablic.txt", Dane.kodyTablic);

        // Wczytaj adresy polskich WORDOW
        Dane.wczytaj_z_pliku("wordy.txt", Dane.adresyOsrodkow);

        // Wczytaj taryfikator mandatow
        Dane.wczytaj_z_pliku("taryfikator.txt", Dane.taryfikator);

        // Wczytaj nazwy miast
        Dane.wczytaj_z_pliku("miejscowosci.txt", Dane.nazwyMiast);

        // Wczytaj kategorie prawa jazdy
        Dane.wczytaj_z_pliku("kategorie_prawa_jazdy.txt", Dane.kategoriePJ);

        // Wczytaj dane o firmach
        Dane.wczytaj_z_pliku("firmy.txt", Dane.firmyTransportowe);

        // Wczytaj dane o zasilaniu pojazdow
        Dane.wczytaj_z_pliku("sposoby_zasilania.txt", Dane.sposobyZasilania);
    }


    public static void main(final String[] args) throws FileNotFoundException {

        wczytaj_dane();

        // Tworzenie miejscowosci (380)
        for (String i : Dane.nazwyMiast) {
            Dane.miejscowosci.add(new Miejscowosc(i));
        }

        // Tworzenie kategorii PJ (14?)
        for (String i : Dane.kategoriePJ) {
            Dane.prawa_jazdy_kategorie.add(new KategoriaPJ(i));
        }

        // Tworzenie wystwiajacych wykroczenia
        for (int i = 0; i < WYST_WYKROCZENIA; ++i) {
            Dane.mandatyWystawiajacy.add(new MandatyWystawiajacy());
        }

        // Tworzenie wykroczen
        for (int i = 0; i < WYKROCZEN; ++i) {
            Dane.wykroczenia.add(new Wykroczenie());
        }

        // Tworzenie egzaminatorow
        for (int i = 0; i < EGZAMINATOROW; ++i) {
            Dane.egzaminatorzy.add(new Egzaminator());
        }

        // Tworzenie firm
        for (String i : Dane.firmyTransportowe) {
            Dane.firmy.add(new Firma(i));
        }

        // Tworzenie osrodkow
        for (int i = 0; i < OSRODKOW; ++i) {
            Dane.osrodki.add(new Osrodek());
        }

        // Tworzenie sposobow zasilania
        for (String i : Dane.sposobyZasilania) {
            Dane.sposob_zasilania.add(new SposobZasilania(i));
        }

        // Tworzenie marek
        for (String i : Dane.samochody) {
            if (!Marka.listId.containsKey(i.split("[|]")[0])) Dane.marka.add(new Marka(i));
        }

        // Tworzenie modeli
        for (int i = 0; i < MODELI; ++i) {
            Dane.model.add(new Model());
        }


        // Tworzenie wlasciwej czesci, tj kierowcow
        for (int i = 0; i < KIEROWCOW; ++i) {
            final Kierowca nowyKierowca = new Kierowca();
            Dane.kierowcy.add(nowyKierowca);
        }

        // Generowanie pliku .sql z zapytaniami
        try (PrintWriter fout = new PrintWriter("myNewQuery.sql")) {

            for (final Miejscowosc X : Dane.miejscowosci) {
                fout.print("INSERT INTO miejscowosc VALUES ");
                fout.print(X);
                fout.println(";");
            }
            for (final KategoriaPJ X : Dane.prawa_jazdy_kategorie) {
                fout.print("INSERT INTO prawa_jazdy_kategorie VALUES ");
                fout.print(X);
                fout.println(";");
            }
            for (final MandatyWystawiajacy X : Dane.mandatyWystawiajacy) {
                fout.print("INSERT INTO mandaty_wystawiajacy VALUES ");
                fout.print(X);
                fout.println(";");
            }
            for (final Wykroczenie X : Dane.wykroczenia) {
                fout.print("INSERT INTO wykroczenia VALUES ");
                fout.print(X);
                fout.println(";");
            }
            for (final Egzaminator X : Dane.egzaminatorzy) {
                fout.print("INSERT INTO egzaminatorzy VALUES ");
                fout.print(X);
                fout.println(";");
            }
            for (final Firma X : Dane.firmy) {
                fout.print("INSERT INTO firma VALUES ");
                fout.print(X);
                fout.println(";");
            }
            for (final Osrodek X : Dane.osrodki) {
                fout.print("INSERT INTO osrodki VALUES ");
                fout.print(X);
                fout.println(";");
            }
            for (final SposobZasilania X : Dane.sposob_zasilania) {
                fout.print("INSERT INTO sposob_zasilania VALUES ");
                fout.print(X);
                fout.println(";");
            }
            for (final Marka X : Dane.marka) {
                fout.print("INSERT INTO marka VALUES ");
                fout.print(X);
                fout.println(";");
            }
            for (final Model X : Dane.model) {
                fout.print("INSERT INTO model VALUES ");
                fout.print(X);
                fout.println(";");
            }
            for (final Kierowca X : Dane.kierowcy) {
                fout.print("INSERT INTO kierowcy VALUES ");
                fout.print(X);
                fout.println(";");
            }
            for (final Egzamin X : Dane.egzaminy) {
                fout.print("INSERT INTO egzaminy VALUES ");
                fout.print(X);
                fout.println(";");
            }
            for (final PrawoJazdy X : Dane.prawaJazdy) {
                fout.print("INSERT INTO prawa_jazdy VALUES ");
                fout.print(X);
                fout.println(";");
            }
            for (final PrawaJazdyKategorie X : Dane.prawa_jazdy_kategorie_praw_jazdy) {
                fout.print("INSERT INTO prawa_jazdy_kategorie_praw_jazdy VALUES ");
                fout.print(X);
                fout.println(";");
            }
            for (final Pojazd X : Dane.pojazdy) {
                fout.print("INSERT INTO pojazdy VALUES ");
                fout.print(X);
                fout.println(";");
            }
            for (final KierowcyPojazdy X : Dane.kierowcyPojazdy) {
                fout.print("INSERT INTO pojazdy_kierowcy VALUES ");
                fout.print(X);
                fout.println(";");
            }
            for (final Mandat X : Dane.mandaty) {
                fout.print("INSERT INTO mandaty VALUES ");
                fout.print(X);
                fout.println(";");
            }

            fout.close();
        }

    }

}
