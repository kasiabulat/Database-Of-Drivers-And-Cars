package controllers;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;

public class VehiclesMoreInfoController {
    @FXML
    private TableView<?> servicingTableView;
    @FXML
    private TableView<?> ownersTableView;
    @FXML
    private Button showButton;
    @FXML
    private TextField id_pojazduTextField;

    @FXML
    public void showInfo(final ActionEvent event) {
        //TODO: show data
    }
    @FXML
    public void initialize() {
        //TODO: fill tableviews
    }
}
