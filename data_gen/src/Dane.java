import java.io.BufferedReader;
import java.io.IOException;
import java.time.LocalDate;
import java.util.*;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

public class Dane {

    // Wczytywane dane z pliku
    public static List<String> imionaDamskie = new ArrayList<>();
    public static List<String> imionaMeskie = new ArrayList<>();

    public static List<String> nazwiskaDamskie = new ArrayList<>();
    public static List<String> nazwiskaMeskie = new ArrayList<>();

    public static List<String> adresy = new ArrayList<>();

    public static List<String> domenyMailowe = new ArrayList<>();

    public static List<String> samochody = new ArrayList<>();

    public static List<String> kodyTablic = new ArrayList<>();

    public static List<String> adresyOsrodkow = new ArrayList<>();

    public static List<String> taryfikator = new ArrayList<>();

    public static List<String> nazwyMiast = new ArrayList<>();

    // Przetrzymywane juz wytworzone krotki
    public static List<Egzaminatorzy> egzaminatorzy = new ArrayList<>();
    public static List<Osrodki> osrodki = new ArrayList<>();
    public static List<MandatyWystawiajacy> mandatyWystawiajacy = new ArrayList<>();
    public static List<Wykroczenia> wykroczenia = new ArrayList<>();

    public static List<Egzaminy> egzaminy = new ArrayList<>();
    public static Map<LocalDate, Integer> egzaminyDaty = new HashMap<>();
    public static Map<Integer, String> egzaminyTypy = new HashMap<>();
    public static List<List<Integer>> egzaminyObecnosc = new ArrayList<>(1000000);
    static {
        for (int i=0; i<1000000; ++i) egzaminyObecnosc.add(new ArrayList<>());
    }

    public static List<WynikiEgzaminow> wynikiEgzaminow = new ArrayList<>();
    public static List<PrawaJazdy> prawaJazdy = new ArrayList<>();
    public static List<PrawaJazdyKategorie> prawaJazdyKategorie = new ArrayList<>();
    public static List<Pojazdy> pojazdy = new ArrayList<>();
    public static List<KierowcyPojazdy> kierowcyPojazdy = new ArrayList<>();
    public static List<Mandaty> mandaty = new ArrayList<>();
    public static List<Kierowca> kierowcy = new ArrayList<>();



    // Funkcja do zrzutu danych do struktur
    static void dodaj(BufferedReader reader, List<String> lista) throws IOException {

        String line = null;
        line = reader.readLine();
        int n = Integer.parseInt(line);

        while(n-- > 0){
            line = reader.readLine();
            lista.add(line);
        }
    }
}
