package controllers;

import database.Database;
import database.Offence;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.TableView;
import javafx.stage.Stage;

import java.io.IOException;

public class OffencesController {
    //TODO: add fields
    @FXML
    private TableView<?> tableView;
    @FXML
    private Button addButton;
    @FXML
    private Button moreInfoButton;
    @FXML
    private Button statisticsButton;

    @FXML
    public void initialize() {
        Database.instance.getOffenceTable((TableView<Offence>) tableView);
    }

    public void addOffence(final ActionEvent event) {
        // TODO: adding offence to database
    }

    @FXML
    public void showMoreInfo(final ActionEvent event) {
        try {
            final Parent root = FXMLLoader.load(getClass().getResource("../FXML/offencesMoreInfoWindow.fxml"));
            final Stage stage = new Stage();
            stage.setTitle("Wykroczenia - szczegółowe informacje");
            stage.setScene(new Scene(root, 450, 310));
            stage.show();

        } catch (final IOException e) {
            e.printStackTrace();
        }
    }

    @FXML
    public void showStatistics(final ActionEvent event) {
        // TODO: show how many offences in each type had been committed, how many which officer had registered etc.
    }
}
