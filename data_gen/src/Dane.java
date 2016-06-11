import java.io.BufferedReader;
import java.io.IOException;
import java.time.LocalDate;
import java.util.*;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

class Dane {

    // Wczytywane dane z pliku
    public static final List<String> imionaDamskie = new ArrayList<>();
    public static final List<String> imionaMeskie = new ArrayList<>();

    public static final List<String> nazwiskaDamskie = new ArrayList<>();
    public static final List<String> nazwiskaMeskie = new ArrayList<>();

    public static final List<String> adresy = new ArrayList<>();

    public static final List<String> domenyMailowe = new ArrayList<>();

    public static final List<String> samochody = new ArrayList<>();

    public static final List<String> kodyTablic = new ArrayList<>();

    public static final List<String> adresyOsrodkow = new ArrayList<>();

    public static final List<String> taryfikator = new ArrayList<>();

    public static final List<String> nazwyMiast = new ArrayList<>();

    // Przetrzymywane juz wytworzone krotki
    public static final List<Egzaminatorzy> egzaminatorzy = new ArrayList<>();
    public static final List<Osrodki> osrodki = new ArrayList<>();
    public static final List<MandatyWystawiajacy> mandatyWystawiajacy = new ArrayList<>();
    public static final List<Wykroczenia> wykroczenia = new ArrayList<>();

    public static final Collection<Egzaminy> egzaminy = new ArrayList<>();
    public static final Map<LocalDate, Integer> egzaminyDaty = new HashMap<>();
    public static final Map<Integer, String> egzaminyTypy = new HashMap<>();
    public static final List<List<Integer>> egzaminyObecnosc = new ArrayList<>(1000000);
    public static final Collection<WynikiEgzaminow> wynikiEgzaminow = new ArrayList<>();
    public static final Collection<PrawaJazdy> prawaJazdy = new ArrayList<>();
    public static final Collection<PrawaJazdyKategorie> prawaJazdyKategorie = new ArrayList<>();
    public static final Collection<Pojazdy> pojazdy = new ArrayList<>();
    public static final Collection<KierowcyPojazdy> kierowcyPojazdy = new ArrayList<>();
    public static final Collection<Mandaty> mandaty = new ArrayList<>();
    public static final Collection<Kierowca> kierowcy = new ArrayList<>();

    static {
        for (int i = 0; i < 1000000; ++i) egzaminyObecnosc.add(new ArrayList<>());
    }

    // Funkcja do zrzutu danych do struktur
    static void dodaj(final BufferedReader reader, final Collection<String> lista) throws IOException {
        String line = reader.readLine();
        int n = Integer.parseInt(line);

        while (n-- > 0) {
            line = reader.readLine();
            lista.add(line);
        }
    }
}
