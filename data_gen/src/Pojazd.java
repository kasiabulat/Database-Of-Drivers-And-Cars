import java.time.LocalDate;
import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-04.
 */

class Pojazd {

    private static final Random rNum = new Random();
    private static int objects;

    private final int id_pojazdu;
    private final String data_rejestracji;
    private String nr_rejestracyjny;
    private String numer_vin;
    private int id_model;
    private String typ;
    private String kraj_produkcji;
    private int waga_samochodu;


    public Pojazd(final LocalDate mozliwaRejestracja) {
        id_pojazdu = ++objects;

        data_rejestracji = FunkcjeLosujace.generuj_date(mozliwaRejestracja.toString(), LocalDate.now().toString());

        Model samochod = Dane.model.get(rNum.nextInt(Dane.model.size()));


        this.id_model = samochod.id_modelu;
        this.typ = samochod.typ_pojazdu;
        this.waga_samochodu = samochod.waga_pojazdu;
        this.numer_vin = "";
        for (int i = 0; i < 8; ++i) {
            this.numer_vin += (char) (rNum.nextInt(10) + 'A');
        }
        for (int i = 0; i < 9; ++i) {
            this.numer_vin += (char) (rNum.nextInt(10) + '0');
        }


        nr_rejestracyjny = "";
        nr_rejestracyjny += Dane.kodyTablic.get(rNum.nextInt(Dane.kodyTablic.size()));
        final int dolosuj = 7 - nr_rejestracyjny.length();
        // nr_rejestracyjny += " ";

        nr_rejestracyjny += (char) (rNum.nextInt(10) + '0');  // Po kodzie powiatu cyfra
        for (int i = 1; i < dolosuj; ++i) {

            nr_rejestracyjny += (char) (rNum.nextInt(2) == 1 && (i == 1 || i == dolosuj - 1 || i == dolosuj - 2) ? rNum
                    .nextInt(26) + 'A' : rNum.nextInt(10) + '0');
        }

        kraj_produkcji = "Polska";

    }

    public int getId_pojazdu() {
        return id_pojazdu;
    }

    @Override
    public String toString() {
        return "(" +
                "" + id_pojazdu +
                ", '" + nr_rejestracyjny + '\'' +
                ", '" + numer_vin + '\'' +
                ", '" + data_rejestracji + '\'' +
                ", " + id_model +
                ", '" + typ + '\'' +
                ", '" + kraj_produkcji + '\'' +
                ", " + waga_samochodu +
                ')';
    }
}
