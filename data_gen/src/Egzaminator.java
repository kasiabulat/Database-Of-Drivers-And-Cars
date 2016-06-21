import java.util.List;
import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

class Egzaminator {

    private static final Random rNum = new Random();
    private static int objects;
    private final int id_egzaminatora;
    private final String imie;
    private final String nazwisko;
    private String numer_licencji;


    public Egzaminator() {
        final int plec = rNum.nextInt(2);

        id_egzaminatora = ++objects;

        final List<String> personalia = FunkcjeLosujace.generuj_imie_nazwisko(plec);
        imie = personalia.get(0);
        nazwisko = personalia.get(1);

        numer_licencji = "";
        for (int i = 0; i < 6; ++i) {
            numer_licencji += (char) (rNum.nextInt(10) + '0');
        }
    }

    public int getId_egzaminatora() {
        return id_egzaminatora;
    }

    @Override
    public String toString() {
        return "(" +
                id_egzaminatora +
                ", '" + imie +
                "', '" + nazwisko +
                "', '" + numer_licencji +
                "')";
    }
}
