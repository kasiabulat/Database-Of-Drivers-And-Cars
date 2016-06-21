import java.time.LocalDate;
import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

class Egzamin {

    private static final Random rNum = new Random();
    private static int objects;
    private final int id_egzaminu;
    private final int id_egzaminatora;
    private final int id_osrodka;
    private String data_przeprowadzenia;
    private String typ;
    private int id_kategoria;
    private int id_kierowcy;
    private String wynik;


    private Egzamin() {
        id_egzaminu = ++objects;

        data_przeprowadzenia = FunkcjeLosujace.generuj_date("1965-01-01", "2016-06-01");

        typ = rNum.nextInt(2) == 0 ? "teoria" : "praktyka";

        id_egzaminatora = Dane.egzaminatorzy.get(rNum.nextInt(Dane.egzaminatorzy.size())).getId_egzaminatora();
        id_osrodka = Dane.osrodki.get(rNum.nextInt(Dane.osrodki.size())).getId_osrodka();
    }

    public Egzamin(final LocalDate data_przeprowadzenia, final String typ, int kategoria, int kierowca, String res) {
        this();
        this.data_przeprowadzenia = data_przeprowadzenia.toString();
        this.typ = typ;
        this.id_kategoria = kategoria;
        this.id_kierowcy = kierowca;
        this.wynik = res;
    }

    public LocalDate getData_przeprowadzenia() {
        LocalDate ret = LocalDate.parse(data_przeprowadzenia);
        return ret;
    }

    @Override
    public String toString() {
        return "(" +
                "" + id_egzaminu +
                ", '" + data_przeprowadzenia + '\'' +
                ", '" + typ + '\'' +
                ", " + id_egzaminatora +
                ", " + id_osrodka +
                ", " + id_kategoria +
                ", " + id_kierowcy +
                ", '" + wynik + '\'' +
                ')';
    }
}
