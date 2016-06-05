import java.time.LocalDate;
import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

public class Egzaminy {

    static int objects = 0;
    static Random rNum = new Random();

    int id_egzaminu;
    String data_przeprowadzenia;
    String typ;
    int id_egzaminatora;
    int id_osrodka;


    public Egzaminy() {
        id_egzaminu = ++objects;

        data_przeprowadzenia = FunkcjeLosujace.generuj_date("1965-01-01", "2016-06-01");

        if(rNum.nextInt(2) == 0) typ = "teoria";
        else typ = "praktyka";

        id_egzaminatora = Dane.egzaminatorzy.get(rNum.nextInt(Dane.egzaminatorzy.size())).getId_egzaminatora();
        id_osrodka = Dane.osrodki.get(rNum.nextInt(Dane.osrodki.size())).getId_osrodka();
    }

    public Egzaminy(LocalDate data_przeprowadzenia, String typ) {
        this();
        this.data_przeprowadzenia = data_przeprowadzenia.toString();
        this.typ = typ;
    }

    public int getId_egzaminu() {
        return id_egzaminu;
    }

    public String getTyp() {
        return typ;
    }

    public String toString() {
        return "(" +
                id_egzaminu +
                ", '" + data_przeprowadzenia +
                "', '" + typ +
                "', " + id_egzaminatora +
                ", " + id_osrodka +
                ")";
    }
}
