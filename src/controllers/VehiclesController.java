package controllers;

import database.Database;
import database.datatypes.Vehicle;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.stage.Stage;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Statement;

public class VehiclesController {
    @FXML
    private TableView<Vehicle> tableView;
    @FXML
    private Button addButton;
    @FXML
    private Button moreInfoButton;
    @FXML
    private Button statisticsButton;

    @FXML
    private TextField id_pojazduTextField;
    @FXML
    private TextField nr_rejestracjiTextField;
    @FXML
    private TextField nr_VINTextField;
    @FXML
    private TextField id_markiTextField;
    @FXML
    private TextField typTextField;
    @FXML
    private TextField id_krajuTextField;
    @FXML
    private TextField waga_samochoduTextField;
    @FXML
    private DatePicker data_rejestracjiPicker;

    @FXML
    public void addVehicle(final ActionEvent event) {
      final String query =
                "INSERT INTO pojazdy VALUES(" +
                        id_pojazduTextField.getText() + ", '" +
                        nr_rejestracjiTextField.getText() +  "', '" +
                        nr_VINTextField.getText() + "', '" +
                        data_rejestracjiPicker.getValue() + "', " +
                        id_markiTextField.getText() + ", '" +
                        typTextField.getText() + "', '" +
                        id_krajuTextField.getText() + "', " +
                        waga_samochoduTextField.getText() + ")";
        try {
            final Statement stmt = Database.instance.connection.createStatement();
            stmt.executeUpdate(query);
        } catch (final SQLException e) {
            e.printStackTrace();
        }
    }

    public void initialize() {
		data_rejestracjiPicker.setTooltip(new Tooltip("Data rejestracji pojazdu"));
	    Database.instance.getVehiclesTable( tableView);

    }

    @FXML
    public void showStatistics(final ActionEvent event) {
        try {
            final Parent root = FXMLLoader.load(getClass().getResource("../FXML/vehiclesStatisticsWindow.fxml"));
            final Stage stage = new Stage();
            stage.setTitle("Pojazdy - statystyki");
            stage.setScene(new Scene(root, 370, 400));
            stage.show();

        } catch (final IOException e) {
            e.printStackTrace();
        }
    }
    @FXML
    public void showMoreInfo(final ActionEvent event) {
        try {
            final Parent root = FXMLLoader.load(getClass().getResource("../FXML/vehiclesMoreInfoWindow.fxml"));
            final Stage stage = new Stage();
            stage.setTitle("Pojazdy - szczegółowe informacje");
            stage.setScene(new Scene(root, 510, 480));
            stage.show();

        } catch (final IOException e) {
            e.printStackTrace();
        }

    }
}
