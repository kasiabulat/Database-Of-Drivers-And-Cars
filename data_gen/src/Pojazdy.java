import java.time.LocalDate;
import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-04.
 */

class Pojazdy {

    private static final Random rNum = new Random();
    private static int objects;
    private final int id_pojazdu;
    private final String data_rejestracji;
    private final String marka;
    private final String model;
    private final String typ;
    private String nr_rejestracyjny;


    public Pojazdy(final LocalDate mozliwaRejestracja) {
        id_pojazdu = ++objects;

        data_rejestracji = FunkcjeLosujace.generuj_date(mozliwaRejestracja.toString(), LocalDate.now().toString());

        final String[] samochod = Dane.samochody.get(rNum.nextInt(Dane.samochody.size())).split(",");
        marka = samochod[0];
        model = samochod[1];

        this.typ = rNum.nextInt(32) == 0 ? "ciężarowy" : "osobowy";

        nr_rejestracyjny = "";
        nr_rejestracyjny += Dane.kodyTablic.get(rNum.nextInt(Dane.kodyTablic.size()));
        final int dolosuj = 7 - nr_rejestracyjny.length();
        nr_rejestracyjny += " ";

        nr_rejestracyjny += (char) (rNum.nextInt(10) + '0');  // Po kodzie powiatu cyfra
        for (int i = 1; i < dolosuj; ++i) {

            nr_rejestracyjny += (char) (rNum.nextInt(2) == 1 && (i == 1 || i == dolosuj - 1 || i == dolosuj - 2) ? rNum
                    .nextInt(26) + 'A' : rNum.nextInt(10) + '0');
        }
    }

    public int getId_pojazdu() {
        return id_pojazdu;
    }

    @Override
    public String toString() {
        return "(" +
                id_pojazdu +
                ", '" + nr_rejestracyjny +
                "', '" + data_rejestracji +
                "', '" + marka +
                "', '" + model +
                "', '" + typ +
                "')";
    }
}
