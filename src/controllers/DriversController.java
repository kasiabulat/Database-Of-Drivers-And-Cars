package controllers;

import database.Database;
import database.datatypes.Driver;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

import java.io.IOException;

public class DriversController {
    @FXML
    private TableView<?> tableView;
    @FXML
    private Button addButton;
    @FXML
    private Button moreInfoButton;

    @FXML
    private TextField id_kierowcyTextField;
    @FXML
    private TextField peselTextField;
    @FXML
    private TextField imieTextField;
    @FXML
    private TextField nazwiskoTextField;
    @FXML
    private TextField plecTextField;
    @FXML
    private TextField emailTextField;
    @FXML
    private TextField nr_telefonuTextField;
    @FXML
    private TextField nr_ulicyTextField;
    @FXML
    private TextField nr_budynkuTextField;
    @FXML
    private TextField kod_pocztowyTextField;
    @FXML
    private TextField nr_miejscowosciTextField;

    @FXML
    public void addDriver(final ActionEvent event) {
        // TODO: adding driver to database using text fields
    }

    @FXML
    public void initialize() {
        Database.instance.getDriversTable((TableView<Driver>) tableView);
    }

    @FXML
    public void showMoreInfo(final ActionEvent event) {
        try {
            final Parent root = FXMLLoader.load(getClass().getResource("../FXML/driversMoreInfoWindow.fxml"));
            final Stage stage = new Stage();
            stage.setTitle("Kierowcy - szczegółowe informacje");
            stage.setScene(new Scene(root, 450, 310));
            stage.show();

        } catch (final IOException e) {
            e.printStackTrace();
        }
    }
}
