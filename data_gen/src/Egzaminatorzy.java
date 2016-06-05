import java.util.List;
import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

public class Egzaminatorzy {

    static int objects = 0;
    static Random rNum = new Random();

    int id_egzaminatora;
    String imie;
    String nazwisko;


    public Egzaminatorzy() {
        int plec = rNum.nextInt(2);

        id_egzaminatora = ++objects;

        List<String> personalia = FunkcjeLosujace.generuj_imie_nazwisko(plec);
        imie = personalia.get(0);
        nazwisko = personalia.get(1);
    }

    public int getId_egzaminatora() {
        return id_egzaminatora;
    }

    public String toString() {
        return "(" +
                id_egzaminatora +
                ", '" + imie +
                "', '" + nazwisko +
                "')";
    }
}
