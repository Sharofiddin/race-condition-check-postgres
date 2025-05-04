package uz.learn.raceconditionspgex;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import reactor.core.publisher.Mono;

import java.math.BigDecimal;

@Service
public class TransferService {

    private final TransferRepository transferRepository;
    public TransferService(TransferRepository transferRepository) {
    	this.transferRepository = transferRepository;
    }
    public Mono<Void> transfer(String fromWallet, String toWallet, BigDecimal amount, String externalId) {
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            return Mono.error(new IllegalArgumentException("Amount must be positive"));
        }
        if (fromWallet.equals(toWallet)) {
            return Mono.error(new IllegalArgumentException("Source and destination wallets cannot be the same"));
        }
        return transferRepository.transfer(fromWallet, toWallet, amount, externalId);
    }
}