/**
 * Created by Michal Stobierski on 2016-06-04.
 */

class KierowcyPojazdy {

    private final int id_kierowcy;
    private final int id_pojazdu;

    public KierowcyPojazdy(final int id_kierowcy, final int id_pojazdu) {
        this.id_kierowcy = id_kierowcy;
        this.id_pojazdu = id_pojazdu;
    }

    @Override
    public String toString() {
        return "(" +
                id_kierowcy +
                ", " + id_pojazdu +
                ')';
    }
}
