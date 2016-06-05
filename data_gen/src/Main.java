import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.Charset;
import java.nio.file.*;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

public class Main {

    static final int EGZAMINATOROW = 32;
    static final int OSRODKOW = 16;
    static final int WYST_WYKROCZENIA = 16;
    static final int WYKROCZEN = 32;
    static final int KIEROWCOW = 100;

    static void wczytaj_dane(BufferedReader reader) throws IOException {

        // Wczytaj imiona damskie
        Dane.dodaj(reader, Dane.imionaDamskie);
        //System.out.println(Dane.imionaDamskie);

        // Wczytaj imiona meskie
        Dane.dodaj(reader, Dane.imionaMeskie);
        //System.out.println(Dane.imionaMeskie);

        // Wczytaj nazwiska damskie
        Dane.dodaj(reader, Dane.nazwiskaDamskie);
        //System.out.println(Dane.nazwiskaDamskie);

        // Wczytaj nazwiska meskie
        Dane.dodaj(reader, Dane.nazwiskaMeskie);
        //System.out.println(Dane.nazwiskaMeskie);

        // Wczytaj adresy
        Dane.dodaj(reader, Dane.adresy);
        //System.out.println(Dane.adresy);

        // Wczytaj domeny mailowe
        Dane.dodaj(reader, Dane.domenyMailowe);
        //System.out.println(Dane.domenyMailowe);

        // Wczytaj marki i modele samochodow
        Dane.dodaj(reader, Dane.samochody);
        //System.out.println(Dane.samochody);

        // Wczytaj polskie tablice samochodowe
        Dane.dodaj(reader, Dane.kodyTablic);
        //System.out.println(Dane.kodyTablic);

        // Wczytaj adresy polskich WORDOW
        Dane.dodaj(reader, Dane.adresyOsrodkow);
        //System.out.println(Dane.adresyOsrodkow);

        // Wczytaj taryfikator mandatow
        Dane.dodaj(reader, Dane.taryfikator);
        //System.out.println(Dane.taryfikator);

        // Wczytaj nazwy miast
        Dane.dodaj(reader, Dane.nazwyMiast);
        //System.out.println(Dane.nazwyMiast);
    }


    public static void main(String[] args) throws FileNotFoundException {

        Path file = Paths.get("files/gen_in_data.in");
        Charset charset = Charset.forName("UTF-8");
        try (BufferedReader reader = Files.newBufferedReader(file, charset)) {
            wczytaj_dane(reader);
        } catch (IOException x) {
            System.err.format("Nie znaleziono pliku z danymi - IOException: %s%n", x);
        }

        // Tworzenie egzaminatorow
        for (int i = 0; i < EGZAMINATOROW; ++i){
            Dane.egzaminatorzy.add(new Egzaminatorzy());
        }

        // Tworzenie osrodkow
        for (int i = 0; i < OSRODKOW; ++i){
            Dane.osrodki.add(new Osrodki());
        }

        // Tworzenie wystwiajacych wykroczenia
        for (int i = 0; i < WYST_WYKROCZENIA; ++i){
            Dane.mandatyWystawiajacy.add(new MandatyWystawiajacy());
        }

        // Tworzenie wykroczen
        for (int i = 0; i < WYKROCZEN; ++i){
            Dane.wykroczenia.add(new Wykroczenia());
        }

        // Tworzenie wlasciwej czesci, tj kierowcow
        for (int i=0; i < KIEROWCOW; ++i){
            Kierowca nowyKierowca = new Kierowca();
            Dane.kierowcy.add(nowyKierowca);
        }

        // Wypis testowy
        PrintWriter fout = new PrintWriter("myNewQuery.sql");

        for(Kierowca X : Dane.kierowcy){
            fout.print("INSERT INTO kierowcy VALUES ");
            fout.print(X);
            fout.println(";");
        }
        for(Egzaminatorzy X : Dane.egzaminatorzy){
            fout.print("INSERT INTO egzaminatorzy VALUES ");
            fout.print(X);
            fout.println(";");
        }
        for(Osrodki X : Dane.osrodki){
            fout.print("INSERT INTO ośrodki VALUES ");
            fout.print(X);
            fout.println(";");
        }
        for(MandatyWystawiajacy X : Dane.mandatyWystawiajacy){
            fout.print("INSERT INTO mandaty_wystawiający VALUES ");
            fout.print(X);
            fout.println(";");
        }
        for(Wykroczenia X : Dane.wykroczenia){
            fout.print("INSERT INTO wykroczenia VALUES ");
            fout.print(X);
            fout.println(";");
        }
        for(Mandaty X : Dane.mandaty){
            fout.print("INSERT INTO mandaty VALUES ");
            fout.print(X);
            fout.println(";");
        }
        for(Egzaminy X : Dane.egzaminy){
            fout.print("INSERT INTO egzaminy VALUES ");
            fout.print(X);
            fout.println(";");
        }
        for(WynikiEgzaminow X : Dane.wynikiEgzaminow){
            fout.print("INSERT INTO wyniki_egzaminów VALUES ");
            fout.print(X);
            fout.println(";");
        }
        for(PrawaJazdy X : Dane.prawaJazdy){
            fout.print("INSERT INTO prawa_jazdy VALUES ");
            fout.print(X);
            fout.println(";");
        }
        for(PrawaJazdyKategorie X : Dane.prawaJazdyKategorie){
            fout.print("INSERT INTO prawa_jazdy_kategorie VALUES ");
            fout.print(X);
            fout.println(";");
        }
        for(Pojazdy X : Dane.pojazdy){
            fout.print("INSERT INTO pojazdy VALUES ");
            fout.print(X);
            fout.println(";");
        }
        for(KierowcyPojazdy X : Dane.kierowcyPojazdy){
            fout.print("INSERT INTO kierowcy_pojazdy VALUES ");
            fout.print(X);
            fout.println(";");
        }

        fout.close();
    }

}
