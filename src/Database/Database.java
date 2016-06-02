package Database;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.cell.PropertyValueFactory;

import java.sql.*;
import java.util.LinkedList;
import java.util.List;

/**
 Created by Kamil Rajtar on 02.06.16. */
final public class Database
{
	/**
	 Only instance of database
	 */
	public static final Database instance=new Database();
	/**
	 Connection to database
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




	private ObservableList<Driver> getDriversList()
	{
		List<Driver> data=new LinkedList<Driver>();

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

	private <S> void insertColumn(TableView<Driver> driversTable,Class<S> typeTag,String name)
	{
		driversTable.setItems(getDriversList());
		final TableColumn<Driver, S> firstNameCol = new TableColumn<>(name);
		firstNameCol.setMinWidth(30);
		firstNameCol.setCellValueFactory(new PropertyValueFactory<>(name));
		driversTable.getColumns().addAll(firstNameCol);

	}

	public void getDriversTable(TableView<?> driversTable)
	{
		if(driversTable==null)
			throw new AssertionError("driversTable==null");
		insertColumn((TableView<Driver>)driversTable,Integer.class,"id_kierowcy");
		insertColumn((TableView<Driver>)driversTable,String.class,"PESEL");
		insertColumn((TableView<Driver>)driversTable,String.class,"imię");
		insertColumn((TableView<Driver>)driversTable,String.class,"nazwisko");
		insertColumn((TableView<Driver>)driversTable,String.class,"email");
		insertColumn((TableView<Driver>)driversTable,String.class,"nr_telefonu");
		insertColumn((TableView<Driver>)driversTable,String.class,"adres");
		((TableView<Driver>)driversTable).setItems(getDriversList());
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
