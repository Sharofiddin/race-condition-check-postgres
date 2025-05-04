package uz.learn.raceconditionspgex;

import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

@Repository
public interface TransferRepository {
    Mono<Void> transfer(String fromWallet, String toWallet, java.math.BigDecimal amount, String externalId);
}
