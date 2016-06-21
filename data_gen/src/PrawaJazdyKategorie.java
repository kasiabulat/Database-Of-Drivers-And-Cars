import java.time.LocalDate;

/**
 * Created by Michal Stobierski on 2016-06-04.
 */

class PrawaJazdyKategorie {

    String data_wygasniecia;
    private String id_prawa_jazdy;
    private int id_kategoria;

    public PrawaJazdyKategorie(final String numer_prawa_jazdy, final int kategoria, LocalDate data_wydania) {
        this.id_prawa_jazdy = numer_prawa_jazdy;
        this.id_kategoria = kategoria;
        data_wygasniecia = data_wydania.plusYears(15).toString();
    }

    @Override
    public String toString() {
        return "(" +
                "'" + id_prawa_jazdy + '\'' +
                ", " + id_kategoria +
                ", '" + data_wygasniecia + '\'' +
                ')';
    }
}
