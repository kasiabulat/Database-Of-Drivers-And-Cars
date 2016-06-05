/**
 * Created by Michal Stobierski on 2016-06-04.
 */

public class KierowcyPojazdy {

    int id_kierowcy;
    int id_pojazdu;

    public KierowcyPojazdy(int id_kierowcy, int id_pojazdu) {
        this.id_kierowcy = id_kierowcy;
        this.id_pojazdu = id_pojazdu;
    }

    @Override
    public String toString() {
        return "(" +
                id_kierowcy +
                ", " + id_pojazdu +
                ")";
    }
}
