package database;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.cell.PropertyValueFactory;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.Collection;
import java.util.LinkedList;

/**
 Created by Kamil Rajtar on 02.06.16. */
final public class Database
{
	/**
	 Only instance of database
	 */
	public static final Database instance=new Database();
	/**
	 database to database
	 */
	public final Connection connection;


	private static final String SERVER_ADRES="localhost";
	private static final String PORT="5433";
	private static final String DB_NAME="kierowcy";
	private static final String USER_NAME="kierowcy";
	private static final String PASSWORD="test";


	/**
	 Constructor
	 */
	private Database()
	{
		try
		{
			Class.forName("org.postgresql.Driver");
			connection=DriverManager.getConnection("jdbc:postgresql://"+SERVER_ADRES+':'+PORT+'/'+DB_NAME,USER_NAME,PASSWORD);
		}catch(ClassNotFoundException|SQLException e)
		{
			throw new DatabaseException(e);
		}
	}




	private static <T,S> void insertColumn(final TableView<T> table,final Class<S> typeTag,final String name,final int minWidth)
	{
		final TableColumn<T, S> firstNameCol = new TableColumn<>(name);
		firstNameCol.setMinWidth(minWidth);
		firstNameCol.setCellValueFactory(new PropertyValueFactory<>(name));
		table.getColumns().addAll(firstNameCol);
	}

	private ObservableList<Driver> getDriversList()
	{
		final Collection<Driver> data=new LinkedList<>();

		try(Statement statement=connection.createStatement();
			ResultSet resultSet=statement.executeQuery("SELECT * FROM kierowcy;"))
		{

			while(resultSet.next())
			{
				data.add(new Driver(resultSet.getInt(1),resultSet.getString(2),resultSet.getString(3),resultSet.getString(4),resultSet.getString(5),resultSet.getString(6),resultSet.getString(7)));
			}
		}catch(final SQLException e)
		{
			throw new DatabaseException(e);
		}
		return FXCollections.observableArrayList(data);
	}

	public void getDriversTable(final TableView<Driver> driversTable)
	{
		insertColumn(driversTable,Integer.class,"id_kierowcy",3);
		insertColumn(driversTable,String.class,"PESEL",30);
		insertColumn(driversTable,String.class,"imię",20);
		insertColumn(driversTable,String.class,"nazwisko",20);
		insertColumn(driversTable,String.class,"email",30);
		insertColumn(driversTable,String.class,"nr_telefonu",10);
		insertColumn(driversTable,String.class,"adres",50);
		driversTable.setItems(getDriversList());
	}


	private ObservableList<Vehicle> getVehiclesList()
	{
		final Collection<Vehicle> data=new LinkedList<>();

		try(Statement statement=connection.createStatement();
			ResultSet resultSet=statement.executeQuery("SELECT * FROM pojazdy;"))
		{
			while(resultSet.next())
			{
				data.add(new Vehicle(resultSet.getInt(1),resultSet.getString(2),resultSet.getDate(3).toLocalDate(),resultSet.getString(4),resultSet.getString(5),resultSet.getString(6)));
			}
		}catch(final SQLException e)
		{
			throw new DatabaseException(e);
		}
		return FXCollections.observableArrayList(data);
	}


	public void getVehiclesTable(final TableView<Vehicle> vehiclesTable)
	{
		insertColumn(vehiclesTable,Integer.class,"id_pojazdu",3);
		insertColumn(vehiclesTable,String.class,"nr_rejestracyjny",30);
		insertColumn(vehiclesTable,LocalDate.class,"data_rejestracji",20);
		insertColumn(vehiclesTable,String.class,"marka",20);
		insertColumn(vehiclesTable,String.class,"model",30);
		insertColumn(vehiclesTable,String.class,"typ",10);
		vehiclesTable.setItems(getVehiclesList());
	}

	private ObservableList<Exam> getExamsList()
	{
		final Collection<Exam> data=new LinkedList<>();

		try(Statement statement=connection.createStatement();
			ResultSet resultSet=statement.executeQuery("SELECT id_egzaminu,data_przeprowadzenia,typ,nazwa,O.adres,E.imię,E.nazwisko,K.imię,K.nazwisko,wynik FROM egzaminy NATURAL JOIN egzaminatorzy E NATURAL JOIN ośrodki O NATURAL JOIN wyniki_egzaminów JOIN kierowcy K USING(id_kierowcy);"))
		{
			while(resultSet.next())
			{
				data.add(new Exam(resultSet.getInt(1),resultSet.getDate(2).toLocalDate(),resultSet.getString(3),resultSet.getString(4),resultSet.getString(5),resultSet.getString(6),resultSet.getString(7),resultSet.getString(8),resultSet.getString(9),resultSet.getString(10)));
			}
		}catch(final SQLException e)
		{
			throw new DatabaseException(e);
		}
		return FXCollections.observableArrayList(data);
	}

	public void getExamsTable(final TableView<Exam> examTable)
	{
		insertColumn(examTable,String.class,"imię_zdającego",30);
		insertColumn(examTable,String.class,"nazwisko_zdającego",10);
		insertColumn(examTable,String.class,"wynik",10);
		insertColumn(examTable,Integer.class,"id_egzaminu",3);
		insertColumn(examTable,LocalDate.class,"data_przeprowadzenia",30);
		insertColumn(examTable,String.class,"typ",20);
		insertColumn(examTable,String.class,"nazwa_ośrodka",20);
		insertColumn(examTable,String.class,"adres_ośrodka",30);
		insertColumn(examTable,String.class,"imię_egzaminatora",10);
		insertColumn(examTable,String.class,"nazwisko_egzaminatora",10);
		examTable.setItems(getExamsList());
	}

	private ObservableList<Offence> getOffenceList()
	{
		final Collection<Offence> data=new LinkedList<>();

		try(Statement statement=connection.createStatement();
			ResultSet resultSet=statement.executeQuery("SELECT K.imię,K.nazwisko,W.opis,W.wysokość_grzywny,W.punkty_karne FROM kierowcy K NATURAL JOIN mandaty M NATURAL JOIN wykroczenia W"))
		{
			while(resultSet.next())
			{
				data.add(new Offence(resultSet.getString(1),resultSet.getString(2),resultSet.getString(3),resultSet.getBigDecimal(4),resultSet.getInt(5)));
			}
		}catch(final SQLException e)
		{
			throw new DatabaseException(e);
		}
		return FXCollections.observableArrayList(data);
	}

	public void getOffenceTable(final TableView<Offence> examTable)
	{
		insertColumn(examTable,String.class,"imię_sprawcy",30);
		insertColumn(examTable,String.class,"nazwisko_sprawcy",30);
		insertColumn(examTable,String.class,"opis",30);
		insertColumn(examTable,BigDecimal.class,"grzywna",30);
		insertColumn(examTable,String.class,"punkty_karne",30);
		examTable.setItems(getOffenceList());
	}

	public String getDriversVehicles(final int driver)
	{
		String pojazdy="";
		try(PreparedStatement preparedStatement=connection.prepareStatement("SELECT pojazdy(?)"))
		{
			preparedStatement.setInt(1,driver);
			try(ResultSet resultSet=preparedStatement.executeQuery())
			{
				while(resultSet.next())
					pojazdy+=resultSet.getString(1)+',';
			}
		}catch(final SQLException e)
		{
			throw new DatabaseException(e);
		}
		if(pojazdy.isEmpty())
			return "";
		return pojazdy.substring(0,pojazdy.length()-1);
	}

	public String getDriverSimpleStringInformation(final String query,final int driver)
	{
		String result;
		try(PreparedStatement preparedStatement=connection.prepareStatement(query))
		{
			preparedStatement.setInt(1,driver);
			try(ResultSet resultSet=preparedStatement.executeQuery())
			{
				if(resultSet.next())
					return resultSet.getString(1);
			}
		}catch(final SQLException e)
		{
			throw new DatabaseException(e);
		}
		throw new IllegalArgumentException("Query did not returned results");
	}




	/*public static void main(String[] args) {
		launch(args);
	}

	public void start() {

		final Label label = new Label("Address Book");
		label.setFont(new Font("Arial", 20));

		table.setEditable(true);

		TableColumn firstNameCol = new TableColumn("First Name");
		firstNameCol.setMinWidth(100);
		firstNameCol.setCellValueFactory(
				new PropertyValueFactory<Person, String>("firstName"));

		TableColumn lastNameCol = new TableColumn("Last Name");
		lastNameCol.setMinWidth(100);
		lastNameCol.setCellValueFactory(
				new PropertyValueFactory<Person, String>("lastName"));

		TableColumn emailCol = new TableColumn("Email");
		emailCol.setMinWidth(200);
		emailCol.setCellValueFactory(
				new PropertyValueFactory<Person, String>("email"));

		table.setItems(data);
		table.getColumns().addAll(firstNameCol, lastNameCol, emailCol);

		final VBox vbox = new VBox();
		vbox.setSpacing(5);
		vbox.setPadding(new Insets(10, 0, 0, 10));
		vbox.getChildren().addAll(label, table);

		((Group) scene.getRoot()).getChildren().addAll(vbox);

		stage.setScene(scene);
		stage.show();
	}

	public static class Person {

		private final SimpleStringProperty firstName;
		private final SimpleStringProperty lastName;
		private final SimpleStringProperty email;

		private Person(String fName, String lName, String email) {
			this.firstName = new SimpleStringProperty(fName);
			this.lastName = new SimpleStringProperty(lName);
			this.email = new SimpleStringProperty(email);
		}

		public String getFirstName() {
			return firstName.get();
		}

		public void setFirstName(String fName) {
			firstName.set(fName);
		}

		public String getLastName() {
			return lastName.get();
		}

		public void setLastName(String fName) {
			lastName.set(fName);
		}

		public String getEmail() {
			return email.get();
		}

		public void setEmail(String fName) {
			email.set(fName);
		}
	}
*/

	/**
	 Standard exception thrown when something wrong with database
	 */
	private static class DatabaseException extends RuntimeException
	{
		/**
		 UID for serialization
		 */
		private static final long serialVersionUID=4187053082188070490L;

		/**
		 Constructor
		 */
		DatabaseException()
		{
			super();
		}

		/**
		 Constructor
		 @param message Message why exception occurred
		 */
		DatabaseException(final String message)
		{
			super(message);
		}

		/**
		 Constructor
		 @param cause Cause of exception
		 */
		DatabaseException(final Throwable cause)
		{
			super(cause);
		}

		/**
		 Constructor
		 @param message Message why exception occurred
		 @param cause   Cause of exception
		 */
		DatabaseException(final String message,final Throwable cause)
		{
			super(message,cause);
		}
	}
}
