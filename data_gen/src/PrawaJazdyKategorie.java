/**
 * Created by Michal Stobierski on 2016-06-04.
 */

public class PrawaJazdyKategorie {

    String numer_prawa_jazdy;
    String kategoria;

    public PrawaJazdyKategorie(String numer_prawa_jazdy, String kategoria) {
        this.numer_prawa_jazdy = numer_prawa_jazdy;
        this.kategoria = kategoria;
    }

    @Override
    public String toString() {
        return "(" +
                "'" + numer_prawa_jazdy +
                "', '" + kategoria +
                "')";
    }
}
