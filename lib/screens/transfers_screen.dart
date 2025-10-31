import 'package:flutter/material.dart';
import '../models/transfer_model.dart';
import '../services/api_service.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return (month >= 1 && month <= 12) ? months[month] : '';
  }

  List<TransferModel> _transferList = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchTransferData();
  }

  Future<void> _fetchTransferData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _transferList = await _apiService.fetchTransfers();
    } catch (e) {
      debugPrint("Error fetching transfer data: $e");
      _transferList = [];
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Pemain')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CurrencyConverterWidget(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Transfer Pemain Terbaru',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transferList.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Text(
                        "Tidak ada data transfer yang ditemukan dari API.",
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _transferList.length,
                    itemBuilder: (context, index) {
                      final transfer = _transferList[index];
                      String formattedDate = '';
                      try {
                        final date = DateTime.parse(transfer.transferDate);
                        formattedDate =
                            '${date.day.toString().padLeft(2, '0')} '
                            '${_monthName(date.month)} '
                            '${date.year}';
                      } catch (_) {
                        formattedDate = transfer.transferDate;
                      }
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 24,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          transfer.playerName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          transfer.status,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      ClipOval(
                                        child: Image.network(
                                          transfer.outTeamLogo,
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.shield,
                                                    size: 32,
                                                    color: Colors.grey,
                                                  ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                          transfer.fromClub,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 18),
                                  const Icon(
                                    Icons.arrow_forward,
                                    size: 28,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 18),
                                  Column(
                                    children: [
                                      ClipOval(
                                        child: Image.network(
                                          transfer.inTeamLogo,
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.shield,
                                                    size: 32,
                                                    color: Colors.grey,
                                                  ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                          transfer.toClub,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class CurrencyConverterWidget extends StatefulWidget {
  const CurrencyConverterWidget({super.key});

  @override
  State<CurrencyConverterWidget> createState() =>
      _CurrencyConverterWidgetState();
}

class _CurrencyConverterWidgetState extends State<CurrencyConverterWidget> {
  final TextEditingController _amountController = TextEditingController();
  String? _sourceCurrency = 'EUR';
  String? _targetCurrency = 'USD';
  String _conversionResult = '0.00 EUR';

  final List<String> _currencies = ['EUR', 'IDR', 'USD', 'GBP', 'JPY'];
  final Map<String, double> _rates = {
    'EUR': 1.0,
    'USD': 1.08,
    'GBP': 0.86,
    'IDR': 18000.0,
    'JPY': 160.0,
  };

  void _convert() {
    final double amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount > 0 && _sourceCurrency != null && _targetCurrency != null) {
      final double rateSource = _rates[_sourceCurrency]!;
      final double rateTarget = _rates[_targetCurrency]!;

      final double amountInEUR = amount / rateSource;
      final double convertedAmount = amountInEUR * rateTarget;

      setState(() {
        _conversionResult =
            '${convertedAmount.toStringAsFixed(2)} $_targetCurrency';
      });
    } else {
      setState(() {
        _conversionResult = 'Input jumlah yang valid';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Currency Converter',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.yellow),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              DropdownButton<String>(
                value: _sourceCurrency,
                items: _currencies.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _sourceCurrency = newValue;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Convert To:'),
              DropdownButton<String>(
                value: _targetCurrency,
                items: _currencies.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _targetCurrency = newValue;
                  });
                },
              ),
              ElevatedButton(onPressed: _convert, child: const Text('Convert')),
            ],
          ),
          const SizedBox(height: 15),

          Text(
            'Result: $_conversionResult',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }
}
