import java.util.List;
import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

public class MandatyWystawiajacy {

    static int objects = 0;
    static Random rNum = new Random();

    int id_wystawiajacego;
    String imie;
    String nazwisko;

    public MandatyWystawiajacy() {
        int plec = rNum.nextInt(2);

        id_wystawiajacego = ++objects;

        List<String> personalia = FunkcjeLosujace.generuj_imie_nazwisko(plec);
        imie = personalia.get(0);
        nazwisko = personalia.get(1);
    }

    public int getId_wystawiajacego() {
        return id_wystawiajacego;
    }

    public String toString() {
        return "(" +
                id_wystawiajacego +
                ", '" + imie +
                "', '" + nazwisko +
                "')";
    }
}
