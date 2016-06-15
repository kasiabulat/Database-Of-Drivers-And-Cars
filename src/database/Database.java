package database;

import database.datatypes.*;
import database.datatypes.Driver;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.cell.PropertyValueFactory;
import org.jetbrains.annotations.NotNull;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.*;
import java.util.Collection;
import java.util.LinkedList;
import java.util.Properties;

/**
 * Created by Kamil Rajtar on 02.06.16.
 */
final public class Database {
    /**
     * Only instance of database
     */
    public static final Database instance = new Database();
    private String SERVER_ADRES;
    private String PORT;
    private String DB_NAME;
    private String USER_NAME;
    private String PASSWORD;
    /**
     * database to database
     */
    public final Connection connection;


    public void loadParams()  {
        Properties props = new Properties();
        InputStream is = null;

        try {
            File f = new File("config.properties");
            is = new FileInputStream(f);
        } catch (Exception e) {
            is = null;
        }

        try {
            if(is == null) {
                is = getClass().getResourceAsStream("config.properties");
            }

            props.load(is);
        } catch (Exception e) {

        }

        SERVER_ADRES = props.getProperty("SERVER_ADRES");
        PORT = props.getProperty("PORT");
        DB_NAME = props.getProperty("DB_NAME");
        USER_NAME = props.getProperty("USER_NAME");
        PASSWORD = props.getProperty("PASSWORD");
    }
    /**
     * Constructor
     */
    private Database() {
        loadParams();

        try {
            Class.forName("org.postgresql.Driver");
            connection = DriverManager.getConnection("jdbc:postgresql://" + SERVER_ADRES + ':' + PORT + '/' + DB_NAME, USER_NAME, PASSWORD);
        } catch (ClassNotFoundException | SQLException e) {
            throw new DatabaseException(e);
        }
    }

    private static <T> void insertColumn(final TableView<T> table,final String name) {
        final TableColumn<T, Object> firstNameCol = new TableColumn<>(name);
        firstNameCol.setPrefWidth(100);
        firstNameCol.setCellValueFactory(new PropertyValueFactory<>(name));
        table.getColumns().addAll(firstNameCol);
    }

    @NotNull
    private ObservableList<Driver> getDriversList() {
        final Collection<Driver> data = new LinkedList<>();

        try (Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery("SELECT * FROM kierowcy;")) {

            while (resultSet.next()) {
                data.add(new Driver(resultSet.getInt(1), resultSet.getString(2), resultSet.getString(3), resultSet.getString(4), resultSet.getString(5), resultSet.getString(6), resultSet.getString(7)));
            }
        } catch (final SQLException e) {
            throw new DatabaseException(e);
        }
        return FXCollections.observableArrayList(data);
    }

    public void getDriversTable(final TableView<Driver> driversTable) {
        insertColumn(driversTable,"id_kierowcy");
        insertColumn(driversTable,"PESEL");
        insertColumn(driversTable,"imię");
        insertColumn(driversTable,"nazwisko");
        insertColumn(driversTable,"email");
        insertColumn(driversTable,"nr_telefonu");
        insertColumn(driversTable,"adres");
        driversTable.setItems(getDriversList());
    }


    @NotNull
    private ObservableList<Vehicle> getVehiclesList() {
        final Collection<Vehicle> data = new LinkedList<>();

        try (Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery("SELECT * FROM pojazdy;")) {
            while (resultSet.next()) {
                data.add(new Vehicle(resultSet.getInt(1), resultSet.getString(2), resultSet.getDate(3).toLocalDate(), resultSet.getString(4), resultSet.getString(5), resultSet.getString(6)));
            }
        } catch (final SQLException e) {
            throw new DatabaseException(e);
        }
        return FXCollections.observableArrayList(data);
    }


    public void getVehiclesTable(final TableView<Vehicle> vehiclesTable) {
        insertColumn(vehiclesTable,"id_pojazdu");
        insertColumn(vehiclesTable,"nr_rejestracyjny");
        insertColumn(vehiclesTable,"data_rejestracji");
        insertColumn(vehiclesTable,"marka");
        insertColumn(vehiclesTable,"model");
        insertColumn(vehiclesTable,"typ");
        vehiclesTable.setItems(getVehiclesList());
    }

    @NotNull
    private ObservableList<Exam> getExamsList() {
        final Collection<Exam> data = new LinkedList<>();

        try (Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery("SELECT id_egzaminu,data_przeprowadzenia,typ,nazwa,O.adres,E.imię,E.nazwisko,K.imię,K.nazwisko,wynik FROM egzaminy NATURAL JOIN egzaminatorzy E NATURAL JOIN ośrodki O NATURAL JOIN wyniki_egzaminów JOIN kierowcy K USING(id_kierowcy);")) {
            while (resultSet.next()) {
                data.add(new Exam(resultSet.getInt(1), resultSet.getDate(2).toLocalDate(), resultSet.getString(3), resultSet.getString(4), resultSet.getString(5), resultSet.getString(6), resultSet.getString(7), resultSet.getString(8), resultSet.getString(9), resultSet.getString(10)));
            }
        } catch (final SQLException e) {
            throw new DatabaseException(e);
        }
        return FXCollections.observableArrayList(data);
    }

    public void getExamsTable(final TableView<Exam> examTable) {
        insertColumn(examTable,"imię_zdającego");
        insertColumn(examTable,"nazwisko_zdającego");
        insertColumn(examTable,"wynik");
        insertColumn(examTable,"id_egzaminu");
        insertColumn(examTable,"data_przeprowadzenia");
        insertColumn(examTable,"typ");
        insertColumn(examTable,"nazwa_ośrodka");
        insertColumn(examTable,"adres_ośrodka");
        insertColumn(examTable,"imię_egzaminatora");
        insertColumn(examTable,"nazwisko_egzaminatora");
        examTable.setItems(getExamsList());
    }

    @NotNull
    private ObservableList<Offence> getOffenceList() {
        final Collection<Offence> data = new LinkedList<>();

        try (Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery("SELECT K.imię,K.nazwisko,W.opis,W.wysokość_grzywny,W.punkty_karne FROM kierowcy K NATURAL JOIN mandaty M NATURAL JOIN wykroczenia W")) {
            while (resultSet.next()) {
                data.add(new Offence(resultSet.getString(1), resultSet.getString(2), resultSet.getString(3), resultSet.getBigDecimal(4), resultSet.getInt(5)));
            }
        } catch (final SQLException e) {
            throw new DatabaseException(e);
        }
        return FXCollections.observableArrayList(data);
    }

    public void getOffenceTable(final TableView<Offence> examTable) {
        insertColumn(examTable,"imię_sprawcy");
        insertColumn(examTable,"nazwisko_sprawcy");
        insertColumn(examTable,"opis");
        insertColumn(examTable,"grzywna");
        insertColumn(examTable,"punkty_karne");
        examTable.setItems(getOffenceList());
    }

    @NotNull
    public String getDriversVehicles(final int driver) {
        String pojazdy = "";
        try (PreparedStatement preparedStatement = connection.prepareStatement("SELECT pojazdy(?)")) {
            preparedStatement.setInt(1, driver);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                while (resultSet.next())
                    pojazdy += resultSet.getString(1) + ',';
            }
        } catch (final SQLException e) {
            throw new DatabaseException(e);
        }
        if (pojazdy.isEmpty())
            return "";
        return pojazdy.substring(0, pojazdy.length() - 1);
    }

    public String getDriverSimpleStringInformation(final String query, final int driver) {
		try (PreparedStatement preparedStatement = connection.prepareStatement(query)) {
            preparedStatement.setInt(1, driver);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next())
                    return resultSet.getString(1);
            }
        } catch (final SQLException e) {
            throw new DatabaseException(e);
        }
        throw new IllegalArgumentException("Query did not returned results");
    }

	@NotNull
	private ObservableList<DangerousDriver> getDangerousDriversList() {
		final Collection<DangerousDriver> data = new LinkedList<>();

		try (Statement statement = connection.createStatement();
			 ResultSet resultSet = statement.executeQuery("SELECT * FROM statystyki_mandatow_najniebezpieczniejsi_kierowcy;")) {
			while (resultSet.next()) {
				data.add(new DangerousDriver(resultSet.getString(1), resultSet.getString(2), resultSet.getInt(3), resultSet.getInt(4)));
			}
		} catch (final SQLException e) {
			throw new DatabaseException(e);
		}
		return FXCollections.observableArrayList(data);
	}

	public void getDangerousDriversTable(final TableView<DangerousDriver> dangerousDriversTable) {
		insertColumn(dangerousDriversTable,"imię");
		insertColumn(dangerousDriversTable,"nazwisko");
		insertColumn(dangerousDriversTable,"ilość_mandatów");
		insertColumn(dangerousDriversTable,"suma_punktów_karnych");
		dangerousDriversTable.setItems(getDangerousDriversList());
	}

	@NotNull
	private ObservableList<ExamCenter> getExamCentersList() {
		final Collection<ExamCenter> data = new LinkedList<>();

		try (Statement statement = connection.createStatement();
			 ResultSet resultSet = statement.executeQuery("SELECT * FROM statystyki_egzaminow_w_zaleznosci_od_osrodka;")) {
			while (resultSet.next()) {
				data.add(new ExamCenter(resultSet.getString(1), resultSet.getString(2), resultSet.getInt(3), resultSet.getInt(4),resultSet.getDouble(5)));
			}
		} catch (final SQLException e) {
			throw new DatabaseException(e);
		}
		return FXCollections.observableArrayList(data);
	}

	public void getExamCenterTable(final TableView<ExamCenter> examCenterTable) {
		insertColumn(examCenterTable,"nazwa");
		insertColumn(examCenterTable,"adres");
		insertColumn(examCenterTable,"zdało");
		insertColumn(examCenterTable,"zdawało");
		insertColumn(examCenterTable,"efektywność");
		examCenterTable.setItems(getExamCentersList());
	}

    @NotNull
    private ObservableList<Firma> getFirmsList() {
        final Collection<Firma> data = new LinkedList<>();

        try (Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery("SELECT * FROM firma NATURAL JOIN miejscowosc")) {
            while (resultSet.next()) {
                data.add(new Firma(resultSet.getInt(1), resultSet.getString(2), resultSet.getString(3), resultSet.getString(4), resultSet.getString(5),
                        resultSet.getString(6), resultSet.getString(7), resultSet.getString(8), resultSet.getString(9), resultSet.getString(10), resultSet.getString(11)));
            }
        } catch (final SQLException e) {
            throw new DatabaseException(e);
        }
        return FXCollections.observableArrayList(data);
    }

    public void getFirmsTable(final TableView<Firma> getFirmsTable) {
        insertColumn(getFirmsTable,"id");
        insertColumn(getFirmsTable, "nip");
        insertColumn(getFirmsTable, "regon");
        insertColumn(getFirmsTable, "numer krs");
        insertColumn(getFirmsTable, "nazwa firmy");
        insertColumn(getFirmsTable, "email");
        insertColumn(getFirmsTable, "nr telefonu");
        insertColumn(getFirmsTable, "ulica");
        insertColumn(getFirmsTable, "nr budynku");
        insertColumn(getFirmsTable, "kod pocztowy");
        insertColumn(getFirmsTable, "miejscowosc");
        getFirmsTable.setItems(getFirmsList());
    }

	/**
     * Standard exception thrown when something wrong with database
     */
    private static class DatabaseException extends RuntimeException {
        /**
         * UID for serialization
         */
        private static final long serialVersionUID = 4187053082188070490L;

        /**
         * Constructor
         */
        DatabaseException() {
            super();
        }

        /**
         * Constructor
         *
         * @param message Message why exception occurred
         */
        DatabaseException(final String message) {
            super(message);
        }

        /**
         * Constructor
         *
         * @param cause Cause of exception
         */
        DatabaseException(final Throwable cause) {
            super(cause);
        }

        /**
         * Constructor
         *
         * @param message Message why exception occurred
         * @param cause   Cause of exception
         */
        DatabaseException(final String message, final Throwable cause) {
            super(message, cause);
        }
    }
}
