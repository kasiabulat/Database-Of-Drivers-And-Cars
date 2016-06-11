package controllers;

import database.Database;
import database.Vehicle;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TableView;

public class VehiclesController {
    @FXML
    private TableView<?> tableView;
    @FXML
    private Button addButton;
    @FXML
    private Button moreInfoButton;

    @FXML
    public void addVehicle(final ActionEvent event) {
        // TODO: adding vehicle to database
    }

    public void initialize() {
        Database.instance.getVehiclesTable((TableView<Vehicle>) tableView);
    }

    @FXML
    public void showMoreInfo(final ActionEvent event) {
        // TODO: show more info about vehicles - some statistic, how many cars in each type, itp.
    }
}
