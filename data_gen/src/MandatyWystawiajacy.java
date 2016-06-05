import java.util.List;
import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

class MandatyWystawiajacy {

    private static int objects;
    private static final Random rNum = new Random();

    private final int id_wystawiajacego;
    private final String imie;
    private final String nazwisko;

    public MandatyWystawiajacy() {
        final int plec = rNum.nextInt(2);

        id_wystawiajacego = ++objects;

        final List<String> personalia = FunkcjeLosujace.generuj_imie_nazwisko(plec);
        imie = personalia.get(0);
        nazwisko = personalia.get(1);
    }

    public int getId_wystawiajacego() {
        return id_wystawiajacego;
    }

    @Override
    public String toString() {
        return "(" +
                id_wystawiajacego +
                ", '" + imie +
                "', '" + nazwisko +
                "')";
    }
}
