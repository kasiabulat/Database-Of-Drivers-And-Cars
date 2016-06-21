import java.io.BufferedReader;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

class Dane {

    // --- Wczytywane dane z pliku ---

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

    public static final List<String> kategoriePJ = new ArrayList<>();

    public static final List<String> firmyTransportowe = new ArrayList<>();

    public static final List<String> sposobyZasilania = new ArrayList<>();

    // --- Przetrzymywane juz wytworzone krotki [lista -> tabela] ---
    public static final List<Miejscowosc> miejscowosci = new ArrayList<>();
    public static final List<KategoriaPJ> prawa_jazdy_kategorie = new ArrayList<>();
    public static final List<MandatyWystawiajacy> mandatyWystawiajacy = new ArrayList<>();
    public static final List<Wykroczenie> wykroczenia = new ArrayList<>();
    public static final List<Egzaminator> egzaminatorzy = new ArrayList<>();
    public static final List<Firma> firmy = new ArrayList<>();
    public static final List<Osrodek> osrodki = new ArrayList<>();
    public static final List<SposobZasilania> sposob_zasilania = new ArrayList<>();
    public static final List<Marka> marka = new ArrayList<>();
    public static final List<Model> model = new ArrayList<>();
    public static final List<Kierowca> kierowcy = new ArrayList<>();
    public static final List<Egzamin> egzaminy = new ArrayList<>();
    public static final List<PrawoJazdy> prawaJazdy = new ArrayList<>();
    public static final List<PrawaJazdyKategorie> prawa_jazdy_kategorie_praw_jazdy = new ArrayList<>();
    public static final List<Pojazd> pojazdy = new ArrayList<>();
    public static final List<KierowcyPojazdy> kierowcyPojazdy = new ArrayList<>();
    public static final List<Mandat> mandaty = new ArrayList<>();

    // Funkcja do otwierania pliku z konkretnymi danymi
    static void wczytaj_z_pliku(String nazwa, final Collection<String> lista) {
        String sciezka = "files/";
        sciezka += nazwa;
        final Path file = Paths.get(sciezka);
        final Charset charset = Charset.forName("UTF-8");
        try (BufferedReader reader = Files.newBufferedReader(file, charset)) {
            dodaj(reader, lista);
            reader.close();
        } catch (final IOException x) {
            System.err.format("Nie znaleziono pliku z danymi - IOException: %s%n" + nazwa, x);
        }
    }

    // Funkcja do zrzutu danych do struktur
    static void dodaj(final BufferedReader reader, final Collection<String> lista) throws IOException {

        String line = reader.readLine();

        while (line != null) {
            lista.add(line);
            line = reader.readLine();
        }
    }
}
