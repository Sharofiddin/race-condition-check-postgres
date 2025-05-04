package uz.learn.raceconditionspgex;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;

@RestController
@RequestMapping("/api/transfers")
public class TransferController {

    private final TransferService transferService;
    
    public TransferController(TransferService transferService) {
    	this.transferService = transferService;
    }

    record TransferRequest(String fromWallet, String toWallet, BigDecimal amount, String externalId) {}

    @PostMapping
    public Mono<Void> transfer(@RequestBody TransferRequest request) {
        return transferService.transfer(
                request.fromWallet(),
                request.toWallet(),
                request.amount(),
                request.externalId()
        );
    }
}