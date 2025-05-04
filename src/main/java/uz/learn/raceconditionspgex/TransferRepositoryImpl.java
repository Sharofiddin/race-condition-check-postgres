package uz.learn.raceconditionspgex;

import io.r2dbc.spi.ConnectionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;

@Component
public class TransferRepositoryImpl implements TransferRepository {

    private final DatabaseClient databaseClient;

    @Autowired
    public TransferRepositoryImpl(ConnectionFactory connectionFactory) {
        this.databaseClient = DatabaseClient.create(connectionFactory);
    }

    @Override
    public Mono<Void> transfer(String fromWallet, String toWallet, BigDecimal amount, String externalId) {
        return databaseClient.sql("SELECT transfer(:from_wallet, :to_wallet, :amount, :external_id)")
                .bind("from_wallet", fromWallet)
                .bind("to_wallet", toWallet)
                .bind("amount", amount)
                .bind("external_id", externalId)
                .then();
    }
}