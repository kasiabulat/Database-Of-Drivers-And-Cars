import java.time.LocalDate;

/**
 * Created by Michal Stobierski on 2016-06-04.
 */

class WynikiEgzaminow {

    private static final int OCZEKIWANIE = 21;
    private final int id_kierowcy;
    private final String wynik;
    private int id_egzaminu;
    // pola pomocnicze, nie uwzgledniane w krotce
    private LocalDate data_przeprowadzenia;

    public WynikiEgzaminow(final int id_kierowcy, final String wynik, final LocalDate data, final String rodzaj) {
        this.id_kierowcy = id_kierowcy;
        this.wynik = wynik;

        for (int i = 0; i < OCZEKIWANIE; ++i) {
            if (Dane.egzaminyDaty.containsKey(data)) {
                this.id_egzaminu = Dane.egzaminyDaty.get(data);
                if (Dane.egzaminyTypy.get(id_egzaminu).equals(rodzaj)) {
                    this.data_przeprowadzenia = data;
                    if (!Dane.egzaminyObecnosc.get(id_egzaminu).contains(id_kierowcy)) {
                        Dane.egzaminyObecnosc.get(id_egzaminu).add(id_kierowcy);
                        return;
                    }
                }
            }
            data.plusDays(1);
        }
        final Egzaminy nowy = new Egzaminy(data, rodzaj);
        Dane.egzaminy.add(nowy);
        Dane.egzaminyTypy.put(nowy.getId_egzaminu(), nowy.getTyp());
        Dane.egzaminyDaty.put(data, nowy.getId_egzaminu());
        this.data_przeprowadzenia = data;
        this.id_egzaminu = nowy.getId_egzaminu();
        Dane.egzaminyObecnosc.get(id_egzaminu).add(id_kierowcy);
    }

    public LocalDate getData() {
        return data_przeprowadzenia;
    }

    @Override
    public String toString() {
        return "(" +
                id_egzaminu +
                ", " + id_kierowcy +
                ", '" + wynik +
                "')";
    }
}
