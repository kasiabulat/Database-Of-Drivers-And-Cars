/**
 * Created by Michal Stobierski on 2016-06-04.
 */

class PrawaJazdyKategorie {

    private final String numer_prawa_jazdy;
    private final String kategoria;

    public PrawaJazdyKategorie(final String numer_prawa_jazdy,final String kategoria) {
        this.numer_prawa_jazdy = numer_prawa_jazdy;
        this.kategoria = kategoria;
    }

    @Override
    public String toString() {
        return "(\'"+ numer_prawa_jazdy +
                "', '" + kategoria +
                "')";
    }
}
